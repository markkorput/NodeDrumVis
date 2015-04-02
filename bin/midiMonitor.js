var midi = require('midi');

// Set up a new input.
var input = new midi.input();

// Count the available input ports.
var cnt = input.getPortCount();

console.log('Midi port count: ' + cnt);

// Get the name of a specified input port.
input.getPortName(0);

for(var i=0; i<cnt; i++)
  console.log('Port '+i+' name: '+ input.getPortName(i));

// Configure a callback.
input.on('message', function(deltaTime, message) {
  console.log('m:' + message + ' d:' + deltaTime);
});

console.log('Monitoring Port ' + (cnt-1));
// Open the first available input port.
input.openPort(cnt-1);

// Sysex, timing, and active sensing messages are ignored
// by default. To enable these message types, pass false for
// the appropriate type in the function below.
// Order: (Sysex, Timing, Active Sensing)
// For example if you want to receive only MIDI Clock beats
// you should use 
// input.ignoreTypes(true, false, true)
input.ignoreTypes(false, true, true);

// ... receive MIDI messages ...

// Close the port when done.
// input.closePort();

module.exports = input;