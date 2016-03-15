var Myo = require('myo');
//myo = Myo.create();
var io = require('socket.io-client');
var socket = io.connect('http://ed614b0f.ngrok.io', {reconnect: true});

socket.connect(); 

// DISABLE LOCKING


// Add a connect listener
socket.on('connect', function() {
  console.log('Client has connected to the server!');
});

socket.emit('notOnWheel');

console.log('Started program.\n');

Myo.connect('com.bd.driver');

Myo.on('connected', function() {
    console.log('Connected!\n');
    console.log(this);
    
    Myo.setLockingPolicy("none");

    
});


Myo.on('pose', function(pose_name){
    console.log('Started ', pose_name);
    
    if (pose_name == "fingers_spread") {
        console.log('emitting event');
        socket.emit('notOnWheel');
    }
    
    if (pose_name == 'fist') {
        console.log('fist on');
        socket.emit('onWheel');
    }
    
    // playskip
    if (pose_name == 'wave_in') {
        console.log('skip song');
        socket.emit('music');
    }
    
});

Myo.on('pose_off', function(pose_name){
    console.log('Ended  ', pose_name);
    
    if (pose_name == "fist") {
        console.log('emitting event');
        socket.emit('notOnWheel');
    }
});


Myo.on('accelerometer', function(data) {
//    console.log(data);
//    sleep(1000);
});


//Myo.trigger('accelerometer');