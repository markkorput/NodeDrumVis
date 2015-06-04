class @Analyser
  constructor: (_opts) ->
    @notes = _opts.notes
    @values = {time: 0.0}
    @clock = _opts.clock

    @notes.on 'add', (note) =>
      @_last = note
      prev = @notes.at(@notes.length-2)
      if prev
        dt = @_last.get('time') - prev.get('time')
        @values.lastNoteBpm = @dtToBpm(dt)

  update: (dt) ->
    @values.time = @clock.getElapsedTime()

    if @_last
      ddt = @values.time - @_last.get('time')
      @values.currentBpm = @dtToBpm(ddt)

  dtToBpm: (dt) ->
    # 60.0 / dt
    15.0 / dt # assuming each hit is a 16th note

  log: (msg) ->
    prefix = 'analyser'

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
