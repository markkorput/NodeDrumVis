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
    @geometries = [new THREE.CubeGeometry(1, 1, 1), new THREE.PlaneGeometry( 5, 20, 32 )]

    # configurables
    @config = new ->
      @enabled = true
      @camSpeed = 0.1
      @spawnPosX = 100
      @spawnPosY = 0
      @spawnPosZ = -30
      @targetPosX = 0
      @targetPosY = 0
      @targetPosZ = -30

    # gui controls
    if @options.gui
      folder = @options.gui.addFolder 'RandomShapes'
      folder.open()
      item = folder.add(@config, 'enabled')
      item = folder.add(@config, 'camSpeed', -2, 2)

    # callbacks
    @notes.on 'add', (note) =>
      mesh = @add(note.get('note'), 1.0)
      note.mesh = mesh

    @notes.on 'remove', (note) =>
      console.log 'removing note...'
      @scene.remove(note.mesh)

    @notes.on 'reset', (collection, options) =>
      console.log 'resetting...'
      _.each options.previousModels, (note) =>
        @scene.remove note.mesh
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
    mesh = new THREE.Mesh(@geometries[0], material)      
    mesh.position.addVectors(@camera.position, new THREE.Vector3(@config.spawnPosX, @config.spawnPosY, @config.spawnPosZ))
    @scene.add mesh

    endPos = new THREE.Vector3(0,0,0)
    endPos.addVectors(@camera.position, new THREE.Vector3(@config.targetPosX, @config.targetPosY, @config.targetPosZ))

    new TWEEN.Tween( mesh.position )
      .to({x: endPos.x, y: endPos.y, z: endPos.z})
      .easing( TWEEN.Easing.Exponential.Out )
      .start()
      .onComplete =>
        console.log 'done'

    return mesh

  update: (dt) ->
    return if @config.enabled != true
    TWEEN.update()
    @camVelocity.z = @config.camSpeed
    @camera.position.add @camVelocity
