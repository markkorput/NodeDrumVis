class @Tiler
  constructor: (_opts) ->
    @log 'constructor: ', _opts
    @options = _opts
    @camera = _opts.camera
    @scene = _opts.scene
    @_notes = _opts.notes
    # @colors = _.map Please.make_color(colors_returned: 20), (clr) -> new THREE.Color(clr)
    @kinds = []
    @setImageUrl(_opts.imageUrl) if _opts.imageUrl

    # configurables
    @config =
      enabled: true
      showOriginal: true

    # gui controls
    if @options.gui
      @options.gui.remember(@config)
      folder = @options.gui.addFolder 'Tiler'
      # folder.open()
      _.each Object.keys(@config), (key) =>
        item = folder.add(@config, key)

    # callbacks
    @_notes.on 'add', (note) =>
      mesh = @add(note.get('note'), 1.0)
      note.set({tilerMesh: mesh})

    @_notes.on 'remove', (note) =>
      @log 'removing note...'
      @scene.remove(note.get('randomShapeMesh'))

    @_notes.on 'reset', (collection, options) =>
      @log 'resetting...'
      _.each options.previousModels, (note) =>
        @scene.remove note.get('randomShapeMesh')
        note.unset('mesh')
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
    
    return mesh

  update: (dt) ->
    return if @config.enabled != true

  log: (msg) ->
    if arguments.length == 1
      console.log('Tiler', msg)
      return

    if arguments.length == 2
      console.log('Tiler', msg, arguments[1])
      return

    if arguments.length == 3
      console.log('Tiler', msg, arguments[1], arguments[2])
      return
    
    console.log('Tiler', msg, arguments[1], arguments[2], arguments[3])

  setImageUrl: (_url) ->
    @log 'setImageUrl: ', _url
    @_imageUrl = _url
    @textureLoader ||= new THREE.TextureLoader();

    onSuccess = (texture) => @setImageTexture texture

    onProgress = (xhr) => @log((xhr.loaded / xhr.total * 100) + '% loaded')

    onError = (xhr) => @log( 'An error happened while loading texture' )

    @textureLoader.load @_imageUrl, onSuccess, onProgress, onError
    
  setImageTexture: (_texture) ->
    @log 'setImageTexture: ', _texture
    @_imageTexture = _texture
    @_imageMaterial = new THREE.MeshBasicMaterial(map: @_imageTexture)
    @_imageGeometry = new THREE.PlaneGeometry(@_imageTexture.image.width / @_imageTexture.image.height,1)
    @_imageMesh = new THREE.Mesh(@_imageGeometry, @_imageMaterial)
    @_imageMesh.position.set(0,0,-1)
    @scene.add @_imageMesh if @config.showOriginal
