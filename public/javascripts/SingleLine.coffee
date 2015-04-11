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
      folder = @options.gui.addFolder 'SingeLine'
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
    mesh = new THREE.Mesh(@geometry, material)      
    mesh.position.addVectors(@camera.position, @relativeSpawnPos)
    mesh.position.y += idx*@geometry.height
    @scene.add mesh
    return mesh

  update: (dt) ->
    return if @config.enabled != true
    @camVelocity.x = @config.camSpeed
    @camera.position.add @camVelocity
