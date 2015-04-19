class @Tiler
  constructor: (_opts) ->
    @log 'constructor: ', _opts
    @options = _opts
    @camera = _opts.camera
    @scene = _opts.scene
    @_notes = _opts.notes
    @colors = _.map Please.make_color(colors_returned: 20), (clr) -> new THREE.Color(clr)
    @kinds = []
    @gridSize = _opts.gridSize
    @setImageUrl(_opts.imageUrl) if _opts.imageUrl

    # configurables
    @config =
      enabled: true
      showOriginal: true
      spacing: 0.0
      colorize: false
      offset: 0.0
      scale: 0.0
      opacity: 1.0
      rotX: 0.0
      rotY: 0.0
      rotZ: 0.0

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
      @scene.remove(note.get('tilerMesh'))

    @_notes.on 'reset', (collection, options) =>
      @log 'resetting...'
      _.each options.previousModels, (note) =>
        @scene.remove note.get('tilerMesh')
        note.unset('tilerMesh')
      @kinds = []
      @cursor.set(0,0,0)

  kindToIndex: (kind) ->
    idx = _.indexOf(@kinds, kind)
    if idx > -1
      return idx
    @kinds.push kind
    return @kinds.length-1

  add: (kind, volume) ->
    return if @config.enabled != true

    tex = @_imageTexture.clone()
    tex.needsUpdate = true # not set by clone, but very much necessary to load the actual image
    material = new THREE.MeshBasicMaterial(map: tex)
    material.color = @colors[@kindToIndex(kind)] if @config.colorize

    # opacity
    if @config.opacity != 1.0
      material.transparent = true
      material.opacity = @config.opacity

    # create and position mesh
    mesh = new THREE.Mesh(@_cellGeometry, material)
    mesh.position.set(
      @_cellOrigin.x + @cursor.x * @cellSize.x + @config.spacing * (@cursor.x - @gridSize.x/2),
      @_cellOrigin.y - @cursor.y * @cellSize.y - @config.spacing * (@cursor.y - @gridSize.y/2),
      @_cellOrigin.z + @cursor.z)

    if @config.offset > 0.0
      offsetter = new THREE.Vector3(@config.offset, 0, 0)
      offsetter.applyAxisAngle(new THREE.Vector3(0,0,1), Math.random()*Math.PI*2)
      mesh.position.add(offsetter)

    # scaling
    if @config.scale != 0.0
      sc = 1.0 + Math.random()*@config.scale
      mesh.scale.set(sc, sc, 1.0)

    # calculate tex coordinates
    tex.repeat.x = 1.0 / @gridSize.x
    tex.repeat.y = 1.0 / @gridSize.y
    tex.offset.x = 1.0 / @gridSize.x * @cursor.x
    tex.offset.y = 1.0 / @gridSize.y * (@gridSize.y-@cursor.y-1)

    # rotate
    mesh.rotation.set(Math.random()*@config.rotX, Math.random()*@config.rotY, Math.random()*@config.rotZ)

    # increase cursor
    @cursor.x = @cursor.x + 1
    if @cursor.x >= @gridSize.x
      @cursor.x = 0
      @cursor.y = @cursor.y + 1
      if @cursor.y >= @gridSize.y
        @cursor.y = 0
        @cursor.z = @cursor.z + 0.001

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
    @loader ||= new THREE.TextureLoader();
    # @loader = new THREE.ImageLoader();

    onSuccess = (tex) => @setImage tex

    onProgress = (xhr) => @log((xhr.loaded / xhr.total * 100) + '% loaded')

    onError = (xhr) => @log( 'An error happened while loading image' )

    @loader.load @_imageUrl, onSuccess, onProgress, onError

  setImage: (_tex) ->
    @log 'setImage: ', _tex
    @_imageTexture = _tex
    @_imageMaterial = new THREE.MeshBasicMaterial(map: @_imageTexture)
    @_imageGeometry = new THREE.PlaneGeometry(@_imageTexture.image.width / @_imageTexture.image.height,1)
    @_imageMesh = new THREE.Mesh(@_imageGeometry, @_imageMaterial)
    @_imageMesh.position.copy(@camera.position)
    @_imageMesh.position.z = @_imageMesh.position.z-1.05 # place _before_ camera
    @scene.add @_imageMesh if @config.showOriginal
    @gridSize ||= new THREE.Vector2(10,10)
    @cellSize = new THREE.Vector2(@_imageGeometry.width / @gridSize.x, @_imageGeometry.height / @gridSize.y)
    @_cellGeometry = new THREE.PlaneGeometry(@cellSize.x, @cellSize.y)
    @_cellOrigin = new THREE.Vector3(
      @_imageMesh.position.x - @_imageGeometry.width /2 + @cellSize.x/2,
      @_imageMesh.position.y + @_imageGeometry.height/2 - @cellSize.y/2,
      @_imageMesh.position.z+0.001)

    @removeTiles()
    @cursor = new THREE.Vector3(0,0,0)

  removeTiles: () ->
    @_notes.each (note) =>
      if m = note.get('tilerMesh')
        @scene.remove m
        note.unset('tilerMesh')



