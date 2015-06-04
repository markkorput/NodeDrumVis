StatsView = Backbone.View.extend
  tagName: 'div'
  className: 'RollsStats'

  initialize: (opts) ->
    @analyser = opts.analyser

    @listenTo @collection, 'change', @render

    Object.observe @analyser.values, (changes) =>
      if changes[0].name == 'time'
        @render()

  render: ->
    @$el.html ''
    @$el.append '<span>Time: '+@analyser.values.time+'</span>' if @analyser
    @$el.append '<span>Number of hits: '+@collection.length+'</span>'
    @$el.append '<span>Last BPM: '+@analyser.values.lastNoteBpm+'</span>' if @analyser
    @$el.append '<span>Current BPM: '+@analyser.values.currentBpm+'</span>' if @analyser

class @Rolls
  constructor: (_opts) ->
    @options = _opts
    @camera = _opts.camera
    @scene = _opts.scene
    @_notes = _opts.notes
    @colors = _.map Please.make_color(colors_returned: 2), (clr) -> new THREE.Color(clr)
    @statsView = new StatsView(collection: @_notes, analyser: _opts.analyser)
    $('body').append(@statsView.el)

    # configurables
    @config =
      enabled: true
      startX: -60
      startY: 30
      startZ: -50
      maxX: 20
      speed: 20
      stepY: -1.5
      minY: -30
      cursor: true

    # gui controls
    if @options.gui
      @options.gui.remember(@config)
      folder = @options.gui.addFolder 'Rolls'
      # folder.open()
      _.each Object.keys(@config), (key) =>
        item = folder.add(@config, key)
      # 'show cursor' param change callback
      _.find(folder.__controllers, (cont) -> cont.property == 'cursor').onChange (cursorEnabled) =>
        return if !@_cursorMesh
        if cursorEnabled
          @scene.add @_cursorMesh
        else
          @scene.remove @_cursorMesh

    @_material = new THREE.LineBasicMaterial()
    @_material.color = @colors[0]
    @_geometry = new THREE.PlaneGeometry(1,1)

    @cursor = new THREE.Vector3(@config.startX, @config.startY, @config.startZ)
    @camera.position.set(0,0,0)

    # callbacks
    @_notes.on 'add', (note) =>
      mesh = @add(note.get('note'), 1.0)
      note.set({rollsMesh: mesh})

    @_notes.on 'remove', (note) =>
      # @log 'removing note...'
      @scene.remove(note.get('rollsMesh'))

    @_notes.on 'reset', (collection, options) =>
      # @log 'resetting...'
      _.each options.previousModels, (note) =>
        @scene.remove note.get('rollsMesh')
        note.unset('rollsMesh')

      @cursor.set(@config.startX, @config.startY, @config.startZ)
      @camera.position.set(0,0,0)

    mat = new THREE.LineBasicMaterial()
    mat.color = @colors[1]
    @_cursorMesh = new THREE.Mesh(@_geometry, mat)
    @_cursorMesh.position.copy(@cursor)
    if @config.cursor
      @scene.add @_cursorMesh

  add: (kind, volume) ->
    return if @config.enabled != true
    mesh = new THREE.Mesh(@_geometry, @_material)      
    mesh.position.copy(@cursor)
    @scene.add mesh
    # @log 'pos', @cursor
    return mesh

  update: (dt) ->
    return if @config.enabled != true

    @cursor.x = @cursor.x + @config.speed * dt
    dx = @cursor.x - @config.maxX
    if dx > 0
      @cursor.x = @config.startX + dx
      @cursor.y += @config.stepY
      dy = @cursor.y - @camera.position.y
      if dy < @config.minY
        @camera.position.y = @cursor.y - @config.minY

    @_cursorMesh.position.copy(@cursor)

  log: (msg) ->
    prefix = 'Rolls'

    if arguments.length == 1
      console.log(prefix, msg)
      return

    if arguments.length == 2
      console.log(prefix, msg, arguments[1])
      return

    if arguments.length == 3
      console.log(prefix, msg, arguments[1], arguments[2])
      return

    console.log(prefix, msg, arguments[1], arguments[2], arguments[3])

  removeTiles: () ->
    @_notes.each (note) =>
      if m = note.get('rollsMesh')
        @scene.remove m
        note.unset('rollsMesh')



