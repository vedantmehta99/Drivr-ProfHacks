//var leapjs = require('leapjs');
//var controller = new leapjs.Controller();
var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var swerve; // pull up

//var isConcentrating = true;

io.on('connection', function(socket){
    console.log("connection");
    
    swerve = 0;

app.get("/", function(req, res){
    res.send("Drivr");
  });

/////////////////////////////////////
//                                 //
//         input from muse         //
//                                 //
/////////////////////////////////////


// according to the muse, is the user focusing?
// note, it is an 'on/off' thing, not a gradient
socket.on('isConcentrating', function(req, res) {
//    isConcentrating = true;
    io.emit("concentrating");
    console.log('concentrating');
});
    
socket.on('isNotConcentrating', function(req, res) {
//    isConcentrating = false;
    io.emit("notConcentrating");
//    console.log('not concentrating');
});
    
// accelerometer data from head!
socket.on('headtilt', function(req, res) {
//   console.log('tilt ' + Math.random()); // to see if there are unique tilts
    io.emit('headIsTilting');
});
//
//function swerve() {
//    if (true)
//        console.log('cutit');
//}
    
/////////////////////////////////////
//                                 //
//         input from myo          //
//                                 //
/////////////////////////////////////
    
// hand NOT on wheel
socket.on('notOnWheel', function(req, res){
    console.log('not on wheel');
    io.emit('handsoff');

});
    
socket.on('onWheel', function(req, res) {
    console.log('on wheel');
    io.emit('handsOn')
});

    // song skipper
socket.on('music', function (req, res) {
    console.log('skip the song');
    io.emit('playskip');
});

    
/////////////////////////////////////
//                                 //
//        input from pebble        //
//                                 //
/////////////////////////////////////

    
  app.get("/right", function(req, res){
    res.send("Right Turn");
    console.log("--------------\nright turn");
    io.emit("right");
    swerve += 7;
    console.log(swerve);
    console.log('--------------\n\n');
      
       
    if ((swerve % 10 == 0)/* && (swerve != 0)*/) {
        console.log('SWERVE');
        swerve = 0;
        io.emit('swerving');
    }
      
  });

  app.get("/left", function(req, res){
    res.send("Left Turn");
    console.log("===============\nleft turn");
    io.emit("left");
    swerve += 3;
    console.log(swerve);
    console.log('===============\n\n');
    
         
    if ((swerve % 10 == 0)/* && (swerve != 0)*/) {
        console.log('SWERVE');
        swerve = 0;
        io.emit('swerving');
    }
      
  });
 

//  controller.on('connect', function() {
//    console.log("Successfully connected.");
//  });
    
    // playskip to skip song
});

// reset swerve score
function reset() {
    swerve = 0;
}

setTimeout(reset, 3000);

http.listen(8000, function(){
  console.log("Listening on *:8000");
});
