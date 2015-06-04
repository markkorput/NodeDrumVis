// Generated by CoffeeScript 1.6.3
this.Analyser = (function() {
  function Analyser(_opts) {
    var _this = this;
    this.notes = _opts.notes;
    this.values = {
      time: 0.0
    };
    this.clock = _opts.clock;
    this.notes.on('add', function(note) {
      var dt, prev;
      _this._last = note;
      prev = _this.notes.at(_this.notes.length - 2);
      if (prev) {
        dt = _this._last.get('time') - prev.get('time');
        return _this.values.lastNoteBpm = _this.dtToBpm(dt);
      }
    });
  }

  Analyser.prototype.update = function(dt) {
    var ddt;
    this.values.time = this.clock.getElapsedTime();
    if (this._last) {
      ddt = this.values.time - this._last.get('time');
      return this.values.currentBpm = this.dtToBpm(ddt);
    }
  };

  Analyser.prototype.dtToBpm = function(dt) {
    return 15.0 / dt;
  };

  Analyser.prototype.log = function(msg) {
    var prefix;
    prefix = 'analyser';
    if (arguments.length === 1) {
      console.log(prefix, msg);
      return;
    }
    if (arguments.length === 2) {
      console.log(prefix, msg, arguments[1]);
      return;
    }
    if (arguments.length === 3) {
      console.log(prefix, msg, arguments[1], arguments[2]);
      return;
    }
    return console.log(prefix, msg, arguments[1], arguments[2], arguments[3]);
  };

  return Analyser;

})();
