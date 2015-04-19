class App
  init: ->
    @notes = new Backbone.Collection()
    @initVfx()
    @initGui()
    @scene = @createScene()

    @clock = new THREE.Clock()
    @controls = new THREE.TrackballControls( @camera, @renderer.domElement )
    
    # callbacks
    $(window).on('keydown', @_keyDown).mousemove(@_mouseMove)#.on('resize', @_resize)
    @notes.on 'add', (note) =>
      return if @notesConfig.maxNotes == 0 || @notes.length <= @notesConfig.maxNotes
      for i in [(@notes.length - @notesConfig.maxNotes - 1)..0]
        console.log 'removing: ', i
        @notes.remove @notes.at(i) 


  update: ->
    dt = @clock.getDelta()
    TWEEN.update()
    if @config.trackballControls
      @controls.update( dt );
    @singleLine.update(dt)
    @randomShapes.update(dt)
    @tiler.update(dt)
    return if @config.paused

  draw: ->
    @renderer.render(@scene, @camera)

  initVfx: ->
    # @camera = new THREE.OrthographicCamera(-100, 100, -100, 100, 0, 1000)
    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)
    # @camera.position.z = 500
    # @camera.lookAt(new THREE.Vector3(0,0,-1))
    
    # @renderer = new THREE.CanvasRenderer()
    @renderer = new THREE.WebGLRenderer({preserveDrawingBuffer: true}) # preserveDrawingBuffer: true allows for image exports, but has some performance implications

    @renderer.setSize(window.innerWidth, window.innerHeight)
    jQuery('body').append(this.renderer.domElement)

  createScene: ->
    scene = new THREE.Scene()
    @singleLine = new SingleLine(scene: scene, camera: @camera, notes: @notes, gui: @gui)
    @randomShapes = new RandomShapes(scene: scene, camera: @camera, notes: @notes, gui: @gui)
    @tiler = new Tiler(scene: scene, camera: @camera, notes: @notes, gui: @gui, imageUrl: 'images/elephant.jpg') #, gridSize: new THREE.Vector2(30, 30))
    return scene

  _resize: ->
    console.log 'TODO; _resize'

  _keyDown: (e) =>
    if @config.logKeys
      console.log 'keycode: ' + e.keyCode, e

    if(@config.keysToNotes)
      @notes.add(note: e.keyCode)

    if(e.keyCode == 32) # space
      @config.paused = (!@config.paused)      

    # if(e.keyCode == 188) # ',' / '<'
    #   @target_system.prevTarget()

    # if(e.keyCode == 190) # '.' / '>'
    #   @target_system.nextTarget()

    # if(e.keyCode == 67) # 'c'
    #   while r = @recorder.first()
    #     @recorder.remove(r)


  initGui: ->
    @gui = new dat.GUI() # ({autoPlace:true});

    @config =
      running: true
      trackballControls: false
      logKeys: false
      keysToNotes: true

    @notesConfig =
      maxNotes: 0

    if @gui
      @gui.remember(@config)
      folder = @gui.addFolder 'App'
      # folder.open()
      _.each Object.keys(@config), (key) =>
        item = folder.add(@config, key)
      folder.add({Reset: => @reset()}, 'Reset')

      @gui.remember(@notesConfig)
      folder = @gui.addFolder 'Notes'
      _.each Object.keys(@notesConfig), (key) =>
        item = folder.add(@notesConfig, key)

  reset: ->
    @notes.reset()
    @camera.position.set(0,0,0)


jQuery(document).ready ->
  window.drawFrame = ->
    requestAnimationFrame(drawFrame)
    if app.config.running
      app.update()
      app.draw()

  window.app = new App()
  window.app.init()
  window.drawFrame()
  console.log('page loaded ok') 