class @RandomShapes
  constructor: (_opts) ->
    @options = _opts
    @camera = _opts.camera
    @scene = _opts.scene
    @notes = _opts.notes
    @colors = _.map Please.make_color(colors_returned: 20), (clr) -> new THREE.Color(clr)
    @kinds = []
    @camVelocity = new THREE.Vector3(0, 0, 0)

    # shapes
    @geometries = [new THREE.PlaneGeometry( 3, 5 )] # new THREE.CubeGeometry(1, 1, 1)

    # configurables
    @config =
      enabled: true
      camSpeed: 0.01
      spawnPosX: 0
      spawnPosY: 0
      spawnPosZ: -3
      spawnPosOffset: 3
      spawnPosRandomize: 3
      spawnRotX: 0
      spawnRotY: 0
      spawnRotZ: 2
      spawnRotOffset: 3
      spawnRotRandomize: 0.01

    # gui controls
    if @options.gui
      @options.gui.remember(@config)
      folder = @options.gui.addFolder 'RandomShapes'
      _.each Object.keys(@config), (key) =>
        item = folder.add(@config, key)

    # callbacks
    @notes.on 'add', (note) =>
      mesh = @add(note.get('note'), 1.0)
      note.set({randomShapeMesh: mesh})

    @notes.on 'remove', (note) =>
      # @log 'removing note...'
      @scene.remove(note.get('randomShapeMesh'))

    @notes.on 'reset', (collection, options) =>
      # @log 'resetting...'
      _.each options.previousModels, (note) =>
        @scene.remove note.get('randomShapeMesh')
        note.unset('randomeShapeMesh')
      @kinds = []

  kindToIndex: (kind) ->
    idx = _.indexOf(@kinds, kind)
    if idx > -1
      return idx
    @kinds.push kind
    return @kinds.length-1

  add: (kind, volume) ->
    return if @config.enabled != true
    material = new THREE.LineBasicMaterial()
    idx = @kindToIndex(kind)
    material.color = @colors[idx]
    mesh = new THREE.Mesh(_.sample(@geometries), material)
    @scene.add mesh
    
    #
    # position
    #

    # randomizer
    offset = new THREE.Vector3(Math.random()*@config.spawnPosRandomize,0,0)
    offset.applyAxisAngle(new THREE.Vector3(0,0,1), Math.random()*Math.PI*2)
    # target pos
    endPos = new THREE.Vector3(@config.spawnPosX, @config.spawnPosY, @config.spawnPosZ)
    endPos.copy(endPos.add(@camera.position).add(offset))
    # 'fly-in' offset
    offset = new THREE.Vector3(@config.spawnPosOffset,0,0)
    offset.applyAxisAngle(new THREE.Vector3(0,0,1), Math.random()*Math.PI*2)
    # set current position of the mesh
    mesh.position.addVectors(endPos, offset)
    # animate to target pos
    new TWEEN.Tween( mesh.position )
      .to({x: endPos.x, y: endPos.y, z: endPos.z})
      .easing( TWEEN.Easing.Exponential.Out )
      .start()
      .onComplete =>
        # console.log 'done'

    #
    # rotation
    #

    # randomizer
    offset = new THREE.Vector3(Math.random()*@config.spawnRotRandomize,0,0)
    offset.applyAxisAngle(new THREE.Vector3(0,0,1), Math.random()*Math.PI*2)
    # target pos
    endRot = new THREE.Vector3(@config.spawnRotX, @config.spawnRotY, @config.spawnRotZ)
    endRot.copy(endRot.add(@camera.position).add(offset))
    # 'fly-in' offset
    offset = new THREE.Vector3(@config.spawnRotOffset,0,0)
    offset.applyAxisAngle(new THREE.Vector3(0,0,1), Math.random()*Math.PI*2)
    startRot = new THREE.Vector3(0,0,0)
    startRot.addVectors(endRot, offset)
    # set current position of the mesh
    mesh.rotation.set(startRot.x, startRot.y, startRot.z)
    # animate to target pos
    new TWEEN.Tween( mesh.rotation )
      .to({x: endRot.x, y: endRot.y, z: endRot.z})
      .easing( TWEEN.Easing.Exponential.Out )
      .start()
      .onComplete =>
        # console.log 'done'

    return mesh

  update: (dt) ->
    return if @config.enabled != true
    @camVelocity.z = @config.camSpeed
    @camera.position.add @camVelocity

  log: (msg) ->
    console.log('RandomShapes', msg)