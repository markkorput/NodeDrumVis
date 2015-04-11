class App
  init: ->
    @notes = new Backbone.Collection()
    @initVfx()
    @initGui()
    @scene = @createScene()

    @clock = new THREE.Clock()
    @controls = new THREE.TrackballControls( @camera, @renderer.domElement )
        
    $(window).on('keydown', @_keyDown).mousemove(@_mouseMove)#.on('resize', @_resize)

  update: ->
    dt = @clock.getDelta()
    if @gui_values.trackballControls
      @controls.update( dt );
    @singleLine.update(dt)
    @randomShapes.update(dt)
    return if @gui_values.paused

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
    return scene

  _resize: ->
    console.log 'TODO; _resize'

  _keyDown: (e) =>
    if @gui_values.logKeys
      console.log 'keycode: ' + e.keyCode, e

    if(@gui_values.keysToNotes)
      @notes.add(note: e.keyCode)

    if(e.keyCode == 32) # space
      @gui_values.paused = (!@gui_values.paused)      

    # if(e.keyCode == 188) # ',' / '<'
    #   @target_system.prevTarget()

    # if(e.keyCode == 190) # '.' / '>'
    #   @target_system.nextTarget()

    # if(e.keyCode == 67) # 'c'
    #   while r = @recorder.first()
    #     @recorder.remove(r)


  initGui: ->
    @gui = new dat.GUI() # ({autoPlace:true});

    @gui_values = new ->
      @trackballControls = false
      @logKeys = false
      @keysToNotes = true
      @running = true

    @gui.remember(@gui_values)
    folder = @gui.addFolder 'Params'
    folder.open()
    item = folder.add(@gui_values, 'running')
    item = folder.add(@gui_values, 'trackballControls')
    item = folder.add(@gui_values, 'logKeys')
    item = folder.add(@gui_values, 'keysToNotes')
    folder.add({Reset: => @reset()}, 'Reset')
    # item.onChange (val) => @visualizer.set(ghost: val)
    
  reset: ->
    @notes.reset()
    @camera.position.set(0,0,0)


jQuery(document).ready ->
  window.drawFrame = ->
    requestAnimationFrame(drawFrame)
    if app.gui_values.running
      app.update()
      app.draw()

  window.app = new App()
  window.app.init()
  window.drawFrame()
  console.log('page loaded ok') 