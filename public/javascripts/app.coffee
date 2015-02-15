class App
  init: ->
    @scene = @createScene()
    @initVfx()

    @clock = new THREE.Clock()
    @controls = new THREE.TrackballControls( @camera, @renderer.domElement )
    @initGui()    
    $(window).on('keydown', @_keyDown).mousemove(@_mouseMove)#.on('resize', @_resize)

  update: ->
    dt = @clock.getDelta()
    @controls.update( dt );
    return if @gui_values.paused

  draw: ->
    @renderer.render(@scene, @camera)

  initVfx: ->
    # @camera = new THREE.OrthographicCamera(-1200, 1000, -1100, 1200, 10, 10000)
    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)
    @camera.position.z = 500
    
    # @renderer = new THREE.CanvasRenderer()
    @renderer = new THREE.WebGLRenderer({preserveDrawingBuffer: true}) # preserveDrawingBuffer: true allows for image exports, but has some performance implications

    @renderer.setSize(window.innerWidth, window.innerHeight)
    jQuery('body').append(this.renderer.domElement)

  createScene: ->
    scene = new THREE.Scene()
    return scene

  _resize: ->
    console.log 'TODO; _resize'

  _keyDown: (e) =>
    console.log 'keycode: ' + e.keyCode

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
      @timer = 0
      @delay = 2
      @paused = false
      @maxTargets = 10
      @currentTarget = 1
      @ghost = true
      @fakeData = false


    folder = @gui.addFolder 'Timing'
    item = folder.add(@gui_values, 'timer', 0, 1)
    item.listen()
    item = folder.add(@gui_values, 'delay', 0, 5)
    # item.onChange (val) => @recorder.autoRecordDelay = val
    item = folder.add(@gui_values, 'paused')
    item.listen()
    folder.open()
    folder = @gui.addFolder 'Targets'
    item = folder.add(@gui_values, 'maxTargets', 1, 30)
    # item.onChange (val) => @target_system.set('maxTargets')
    item = folder.add(@gui_values, 'currentTarget', 1, 10)
    item.listen()
    item = folder.add(@gui_values, 'ghost')
    # item.onChange (val) => @visualizer.set(ghost: val)
    folder.open()
    folder = @gui.addFolder 'Debug'
    item = folder.add(@gui_values, 'fakeData')
    # item.onChange (val) => @myoManager.enableDummyData(val)
    folder.open()


jQuery(document).ready ->
  window.drawFrame = ->
    requestAnimationFrame(drawFrame)
    app.update()
    app.draw()

  window.app = new App()
  window.app.init()
  window.drawFrame()
  console.log('page loaded ok') 