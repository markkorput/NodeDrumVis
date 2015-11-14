MidiInterfaceView = Backbone.View.extend
  tagName: 'div'
  className: 'midi-interface-view'

  events:
    'change select': 'onPortSelect'

  initialize: (opts) ->
    @render()
    @collection.on 'reset', @render, this

  render: ->
    if !@collection
      @$el.html('No MIDI port information available')
      return

    if @collection.length == 0
      @$el.html('No MIDI ports')

    select = jQuery('<select></select>')
    select.append('<option value="none">Midi Port Disabled</option>');
    @collection.each (midi_port) ->
      select.append('<option value="'+midi_port.id+'">'+midi_port.get('name')+'</option>')
    @$el.html('')
    @$el.append(select)

  onPortSelect: (e) ->
    @trigger('port_selected', @$el.find('select').val());



class @MidiInterface
  constructor: (_opts) ->
    @options = _opts

    # setup midi ports collection
    @midi_ports ||= new Backbone.Collection()

    # this callback automatically send an enable/disable request to the server
    # when any of the midi ports' 'open' property change
    @midi_ports.on 'change:open', (model, value, obj) =>
      if !@socket
        @log "No socket initialized, can't request open/close midi port"
        return

      if value == true
        @socket.emit('POST /midi_port', {id: model.id, forward: true})

      if value == false && model.previous('open') == true
        @socket.emit('POST /midi_port', {id: model.id, forward: false})

    @init()

    # UI view with midi port select input
    @midi_interface_view = new MidiInterfaceView(collection: @midi_ports)
    $('body').append(@midi_interface_view.el)
    @midi_interface_view.on 'port_selected', @changePort, this

  changePort: (port_id) ->
    # @log('TODO: change port to:', @midi_ports.get(port_id).get('name'))

    # make sure all ports are closed (ie. close any open ports)
    @midi_ports.each (midi_port) ->
      midi_port.set(open: false)

    # open the specified port
    if midi_port = @midi_ports.get(port_id)
      midi_port.set(open: true)

  init: ->
    if typeof(io) == 'undefined'
    	@log "IO module not loaded, can't establish socket connection with server"
    else
    	# @log("Creating socket connection...")
    	@socket = io.connect 'http://localhost'

    if @socket
    	@socket.on 'ack', (data) =>
    		# @log "Respondig to ack", data
    		@socket.emit 'ack', "Ack received"

      @socket.on 'midi', (data) =>
        # console.log 'myo-orientation'
        # console.log data
        @log "Got midi msg", data
        # @onOrientation data

      @socket.on 'midi_ports', (data) =>
      	# @log 'Received midi_ports with: ', data
      	@midi_ports.reset(data)

      	
      # @log 'Requesting available midi ports'
      @socket.emit('GET /midi_ports')

  log: (msg) ->
    prefix = 'MidiInterface'

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


