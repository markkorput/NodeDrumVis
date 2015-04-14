class @SingleLine
  constructor: (_opts) ->
    @options = _opts
    @camera = _opts.camera
    @scene = _opts.scene
    @notes = _opts.notes
    @colors = _.map Please.make_color(colors_returned: 20), (clr) -> new THREE.Color(clr)
    @geometry = new THREE.CubeGeometry(1, 1, 1)
    @relativeSpawnPos = new THREE.Vector3(0, 0, -30)
    @kinds = []
    @camVelocity = new THREE.Vector3(0, 0, 0.001)

    # configurables
    @config = new ->
      @enabled = true
      @camSpeed = 0.1

    # gui controls
    if @options.gui
      @options.gui.remember @config
      folder = @options.gui.addFolder 'SingleLine'
      _.each Object.keys(@config), (key) =>
        item = folder.add(@config, key)
      

    # callbacks
    @notes.on 'add', (note) =>
      mesh = @add(note.get('note'), 1.0)
      note.set({singleLineMesh: mesh})

    @notes.on 'remove', (note) =>
      @log 'removing note...'
      @scene.remove(note.get('singleLineMesh'))

    @notes.on 'reset', (collection, options) =>
      @log 'resetting...'
      _.each options.previousModels, (note) =>
        @scene.remove note.get('singleLineMesh')
        note.unset('singleLineMesh')
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
    mesh = new THREE.Mesh(@geometry, material)      
    mesh.position.addVectors(@camera.position, @relativeSpawnPos)
    mesh.position.y += idx*@geometry.height
    @scene.add mesh
    return mesh

  update: (dt) ->
    return if @config.enabled != true
    @camVelocity.x = @config.camSpeed
    @camera.position.add @camVelocity

  log: (msg) ->
    console.log('SingleLine', msg)

