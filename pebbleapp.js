var ajax = require('ajax');
var UI = require('ui');
var Vector2 = require('vector2');
var Accel = require('ui/accel');

var sumx = 0;
var sumy = 0;
var sumz = 0;
var counter = 0;

var initialx = 0;
var initialy = 0;
var initialz = 0;

var finalx = 0;
var finaly = 0;
var finalz = 0;

var main = new UI.Card({
  title: 'Team BD',
  subtitle: 'Pebble Tennis',
  body: 'Enjoy.'
});

main.show();

// button listener to start the game
main.on('click', 'up', function(e) {
       
     ajax(
          {
               url: 'http://beff0643.ngrok.io/startgame',
               method: 'get',
               type: 'json',
               crossDomain: true
          });
     
     // display a message saying session has started
      var card = new UI.Card();
       card.title('Session');
       card.subtitle('started');
       card.body('Good luck!');
       card.show();
     
     console.log("Started new game");
     
});


// button listener to end the game
main.on('click', 'down', function(e) {
       
     ajax(
          {
               url: 'http://beff0643.ngrok.io/endgame',
               method: 'get',
               type: 'json',
               crossDomain: true
          });
     
       // display a message saying session has started
      var card = new UI.Card();
       card.title('Session');
       card.subtitle('ended');
       card.body('Check your phone/email!');
       card.show();
     
     console.log("Ended game");
     
});



var mallu = function() {
     
     
     Accel.on('data', function(e) {
          
          Accel.config(25, 1, true);
          
          var x = e.accel.x;
          var y = e.accel.y;
          var z = e.accel.z;
           
          console.log(x + ", " + y + ", " + z);

          if (x - initialx <= -50 && y - initialy >= 50){
            if (z < initialz){
              console.log("right turn");
              console.log("right turn");
              console.log("right turn");
              console.log("right turn");
              console.log("right turn");
              console.log("right turn");
              console.log("right turn");
              console.log("__________");
              ajax(
                  {
                    url: 'http://9df52fac.ngrok.io/right',
                    method: 'get',
                    crossDomain: true
                  });
            }
            else if (z > initialz){
              console.log("left turn");
              console.log("left turn");
              console.log("left turn");
              console.log("left turn");
              console.log("left turn");
              console.log("left turn");
              console.log("left turn");
              console.log("__________");
               ajax(
                  {
                    url: 'http://9df52fac.ngrok.io/left',
                    method: 'get',
                    crossDomain: true
                  });
            }
          }
       
       initialx = x;
       initialy = y;
       initialz = z;
          
//           // from 1-4, get initial values
//           if (counter < 5) {
//                initialx += x;
//                initialx = initialx / counter;
               
//                initialy += y;
//                initialy = initialy / counter;
               
//                initialz += z;
//                initialz = initialz / counter;
               
//                console.log(initialx + " " + initialy);
               
//           }
          
//           // from 14 to 19, get final values
//           if (counter >= 14 && counter <= 19) {
//                finalx += x;
//                finalx = finalx / counter;
               
//                finaly += y;
//                finaly = finaly / counter;
               
//                finalz += z;
//                finalz = finalz / counter;
               
//                console.log(finalx + ", " + finaly + ", " + finalz);
               
//           }
          
//           var averagex = sumx / counter;
//           var averagey = sumy / counter;
//           var averagez = sumz / counter;
          
//           if (counter == 20) {
               
//                console.log("\n\nRESETTING AND SENDING THE ANALYSIS\n\n");
          
//                var isTopspin;
               
//                var isForehand;
               
//                // topspin or slice? (for forehand)
//                var deltax = finalx - initialx;
//                var deltay = finaly - initialy;
//                var deltaz = finalz - initialz;
               
//                // detect forehand or backhand
//                if (deltax < 0) {
//                     // forehand
//                     isForehand = true;
//                     console.log("\nfOrEhAnD\n");
                    
//                     // emit the post request
//                     ajax(
//                   {
//                     url: 'http://beff0643.ngrok.io/forehand',
//                     method: 'get',
//                     crossDomain: true
//                   });
                    
//                }
               
//                else if (deltax > 0) {
//                     // backhand
//                     isForehand = false;
//                     console.log("\nbAcKhAnD\n");
                    
//                     ajax(
//                   {
//                     url: 'http://beff0643.ngrok.io/backhand',
//                     method: 'get',
//                     crossDomain: true
//                   });
                    
//                }
               
               
               
//                // detect topspin or slice
//                if (deltaz > 0 && deltax < 0 && deltay > 0) {
//                     // topspin
//                     isTopspin = true;
//                     console.log("\nSLICE\n");
// //                     post
                    
//                      ajax(
//                   {
//                     url: 'http://beff0643.ngrok.io/topspin',
//                     method: 'get',
//                     type: 'json',
//                     crossDomain: true
//                   });
                    
                    
//                }
//                else if (deltaz < 0){
//                     isTopspin = false;
//                     console.log("\ntopspin\n");
                    
// //                     post
//                      ajax(
//                   {
//                     url: 'http://beff0643.ngrok.io/slice',
//                     method: 'get',
//                     type: 'json',
//                     crossDomain: true
//                   });
                    
                    
//                }
               
//                else {
//                     console.log("\nNEITHER\n");
//                }
               
               
//                // send the goods
//                var packet = {
//                     x:averagex,
//                     y:averagey,
//                     z:averagez
//                };
               
//                // emit the goods
//                ajax(
//              {
//                url: 'http://beff0643.ngrok.io/coordinates',
//                method: 'post',
//                type: 'json',
//                data: packet,
//                crossDomain: true
//              });
               
//                // reset the mallus
//                counter = 1;
               
//                sumx = x;
//                sumy = y;
//                sumz = z;
               
//                averagex = sumx;
//                averagey = sumy;
//                averagez = sumz;
          
               
//           }
               
//           console.log("\n\n\nAverages: " + averagex + " " + averagey + " " + averagez);
//           console.log('Just received ' +  x + ',' + y + ','  + z + ' from the accelerometer.');
          
     });
     
};




var accel2 = function() {
     Accel.init();
     
     console.log("accel2 is called");
     
     setInterval(mallu, 10000);
     
     
     
     
};


accel2();
