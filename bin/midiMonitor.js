var midi = require('midi');
midi.ports = [];

function midiMonitor(opts){
	var instance = {opts: opts, midi: midi};

	instance.getPortsData = function(){
		input = new this.midi.input();
		data = []

		// Count the available input ports.
		var cnt = input.getPortCount();
		for(var i=0; i<cnt; i++)
			data.push({id: i, name: input.getPortName(i), index: i})

		return data;
	};

	instance.openPort = function(port_id){
		var self = this;

		for(var i=this.midi.ports.length-1; i>=0; i--){
			if(midi.ports[i].port_id == port_id){
				console.log('Port already open, ignoring request');
				return;
			}
		}

		// create new input instance
		var input = new this.midi.input();

		// these custom properties are for our own reference (to find and close these ports later)
		input.port_id = port_id;
		input.port_name = input.getPortName(port_id);

		// log activity with port name
		console.log('Opening port: ', input.port_name);

		// store newly created instance in our 'global' array of active ports
		this.midi.ports.push(input);

		// // Configure a callback.
		input.on('message', function(deltaTime, message) {
		  // console.log('MIDI msg, m:' + message + ' d:' + deltaTime);
		  if(self.opts.socket){
		  	self.opts.socket.emit('midi-msg', {msg: message, dt: deltaTime});
		  }
		});

		// Sysex, timing, and active sensing messages are ignored
		// by default. To enable these message types, pass false for
		// the appropriate type in the function below.
		// Order: (Sysex, Timing, Active Sensing)
		// For example if you want to receive only MIDI Clock beats
		// you should use 
		// input.ignoreTypes(true, false, true)
		input.ignoreTypes(false, true, true);

		// open it up!
		input.openPort(port_id);
	};

	instance.closePort = function(port_id){
		for(var i=this.midi.ports.length-1; i>=0; i--){
			var port = this.midi.ports[i];

			if(port.port_id == port_id){
				console.log('Closing midi port:', port.port_name);
				// close it
				port.closePort();
				// remove it fom the array
				midi.ports.splice(i, 1);
			}
		}
	};

	instance.registerSocketCallbacks = function(){
		var self = this;

		// register some socket callbacks
		if(!this.opts.socket){
			console.log('No socket available to register callbacks');
			return;
		}

		// list available midi ports
		this.opts.socket.on('GET /midi_ports', function(data){
			data = self.getPortsData();
			console.log('Responding to "GET /midi_ports" with', data);
			self.opts.socket.emit('midi_ports', data);
		});

		// update (open/close) midi port
		opts.socket.on('POST /midi_port', function(data){
			console.log('received POST /midi_port with', data);

			if(data.id && data.forward == true){
				self.openPort(data.id);
			}

			if(data.id && data.forward == false){
				self.closePort(data.id);
			}
		});
	};

	instance.init = function(){
		this.registerSocketCallbacks();
	};

	instance.init();

	return instance;
}

module.exports = midiMonitor;