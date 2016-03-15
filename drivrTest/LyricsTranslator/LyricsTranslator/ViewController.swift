//
//  ViewController.swift
//
//

import UIKit
import AVFoundation
import HealthKit
import Foundation
import CoreLocation
import MediaPlayer
import WatchConnectivity

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

class ViewController: UIViewController, WCSessionDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var turnView = UIImageView()
    
    var allLocations: [CLLocation] = [CLLocation]()
    
    var allowNewSong = true
    
    var player = MPMusicPlayerController()
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer? // Master layer where all the other stuff is layed on top of yerexcept this is on replcator layer
                                                    // whose idea was this
    
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://9df52fac.ngrok.io/")!)
    
    // hardcoded array of languages
//    let languages = ["en", "es", "ru", "de", "hi", "it", "ko", "pl", "pt", "he"]
//    
//  
//    @IBOutlet weak var languagePicker: UIPickerView!
//    
//    @IBOutlet weak var songTextField: UITextField!
//    
//    @IBOutlet weak var artistTextField: UITextField!
    
    
    let lyricsLayer: CATextLayer = CATextLayer() // Displays lyrics
    let speedometerLayer: CATextLayer = CATextLayer()
    let directionLayer: CATextLayer = CATextLayer()
    var concentrationLayer: CATextLayer = CATextLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // connect the socket
        socket.connect()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 1;
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()

        
        socket.on("right") {data, ack in
            
            self.turnView.image = UIImage(named: "turn_right")
            
        }
        socket.on("left") {data, ack in
            
            self.turnView.image = UIImage(named: "turn_left")
            
        }
        socket.on("not concentrating") {data, ack in
            self.concentrationLayer.font = "Not Concentrating"
            self.concentrationLayer.fontSize = 24
            self.concentrationLayer.frame = CGRectMake(40, 40, 311, 311) // x, y, width, heights NOTE: THE LYRICSLAYER STARTS AT 0,0, BUT THE CAMERA VIEW IS LOWER THAN THIS
            self.concentrationLayer.alignmentMode = kCAAlignmentCenter
            self.concentrationLayer.string = "0.0 MPH"
            self.concentrationLayer.foregroundColor = UIColor.whiteColor().CGColor
            
            
        }
        socket.on("concentrating") {data, ack in
            self.concentrationLayer.font = "Concentrating"
            self.concentrationLayer.fontSize = 24
            self.concentrationLayer.frame = CGRectMake(40, 40, 311, 311) // x, y, width, heights NOTE: THE LYRICSLAYER STARTS AT 0,0, BUT THE CAMERA VIEW IS LOWER THAN THIS
            self.concentrationLayer.alignmentMode = kCAAlignmentCenter
            self.concentrationLayer.string = "0.0 MPH"
            self.concentrationLayer.foregroundColor = UIColor.whiteColor().CGColor
            
            
        }
        socket.on("playskip") {data, ack in
            
            if (self.allowNewSong){
                let mediaItems = MPMediaQuery.songsQuery().items
                let mediaCollection = MPMediaItemCollection(items: mediaItems!)
                
                self.player = MPMusicPlayerController.systemMusicPlayer()
                self.player.setQueueWithItemCollection(mediaCollection)
                
                self.player.play()
                
                print(self.player.nowPlayingItem?.title)
                
                self.lyricsLayer.font = "Helvetica"
                self.lyricsLayer.fontSize = 13
                self.lyricsLayer.frame = CGRectMake(0, 0, 311, 311) // x, y, width, heights NOTE: THE LYRICSLAYER STARTS AT 0,0, BUT THE CAMERA VIEW IS LOWER THAN THIS
                self.lyricsLayer.alignmentMode = kCAAlignmentCenter
                self.lyricsLayer.string = "\((self.player.nowPlayingItem?.title!)!) - \((self.player.nowPlayingItem?.artist!)!)"
                self.lyricsLayer.foregroundColor = UIColor.whiteColor().CGColor
                
                self.allowNewSong = false
            }
            
            _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "songwait", userInfo: nil, repeats: false)
            
        }

        
    }
    
    func songwait() {
        allowNewSong = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.magneticHeading)
        self.directionLayer.font = "Helvetica"
        self.directionLayer.fontSize = 13
        self.directionLayer.frame = CGRectMake(0, 30, 311, 311) // x, y, width, heights NOTE: THE LYRICSLAYER STARTS AT 0,0, BUT THE CAMERA VIEW IS LOWER THAN THIS
        self.directionLayer.alignmentMode = kCAAlignmentCenter
        
        if ((newHeading.magneticHeading > 315 && newHeading.magneticHeading < 360) || (newHeading.magneticHeading > 0 && newHeading.magneticHeading < 45)) {
            self.directionLayer.string = "North"
        }
        else if ((newHeading.magneticHeading > 45 && newHeading.magneticHeading < 90) || (newHeading.magneticHeading > 90 && newHeading.magneticHeading < 135)) {
            self.directionLayer.string = "East"
        }
        else if ((newHeading.magneticHeading > 135 && newHeading.magneticHeading < 180) || (newHeading.magneticHeading > 180 && newHeading.magneticHeading < 225)) {
            self.directionLayer.string = "South"
        }
        else {
            self.directionLayer.string = "West"
        }
        
        
        self.directionLayer.foregroundColor = UIColor.whiteColor().CGColor
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            //print(locations.last?.coordinate.latitude)
        
        allLocations.append(locations.last!)
        
        if (allLocations.count >= 2){
        
            let l1 = allLocations[allLocations.count-2]
            let l2 = allLocations[allLocations.count - 1]
            
            let cl1 = CLLocation(latitude: l1.coordinate.latitude, longitude: l1.coordinate.longitude)
            let cl2 = CLLocation(latitude: l2.coordinate.latitude, longitude: l2.coordinate.longitude)
            
            let distance = cl2.distanceFromLocation(cl1)
            let time = l2.timestamp.timeIntervalSinceDate(l1.timestamp)
            let speed = distance/time
            
            print(speed * 2.23694)
            speedometerLayer.string = "\((speed * 2.23694).format("0.1")) MPH"
        }
        
    }
    
    @IBAction func playSkip(sender: AnyObject) {
        let mediaItems = MPMediaQuery.songsQuery().items
        let mediaCollection = MPMediaItemCollection(items: mediaItems!)
        
        let player = MPMusicPlayerController.systemMusicPlayer()
        player.setQueueWithItemCollection(mediaCollection)
        
        player.play()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input = try! AVCaptureDeviceInput(device: backCamera)
        
        //var input = AVCaptureDeviceInput(device: backCamera, error: &error)
        var output: AVCaptureVideoDataOutput?
        
        if captureSession?.canAddInput(input) != nil {
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            output = AVCaptureVideoDataOutput()
            
            if (captureSession?.canAddOutput(output) != nil) {
                
                //captureSession?.addOutput(stillImageOutput)
                captureSession?.addOutput(output)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.frame = CGRect(x: 13, y: 30, width: 360, height:  self.view.bounds.size.height - 70)
                //previewLayer?.frame = CGRect(self.view.bounds)
                
                let replicatorLayer = CAReplicatorLayer()
                //replicatorLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width / 2, self.view.bounds.size.height)
                replicatorLayer.frame = CGRectMake(13, 30, 360, self.view.bounds.size.height - 70)
                replicatorLayer.instanceCount = 2
                //replicatorLayer.instanceTransform = CATransform3DMakeTranslation(self.view.bounds.size.width / 2, 0.0, 0.0)
                replicatorLayer.instanceTransform = CATransform3DMakeTranslation(310, 0.0, 0.0)
                
                //replicatorLayer.instanceTransform = CATransform3DMakeTranslation(0.0, self.view.bounds.size.height / 2, 0.0)
                
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                
                // setup the layer
                
                speedometerLayer.font = "Helvetica"
                speedometerLayer.fontSize = 24
                speedometerLayer.frame = CGRectMake(80, 260, 311, 311) // x, y, width, heights NOTE: THE LYRICSLAYER STARTS AT 0,0, BUT THE CAMERA VIEW IS LOWER THAN THIS
                speedometerLayer.alignmentMode = kCAAlignmentCenter
                speedometerLayer.string = "0.0 MPH"
                speedometerLayer.foregroundColor = UIColor.whiteColor().CGColor
                
                previewLayer?.addSublayer(directionLayer)
                
                previewLayer?.addSublayer(lyricsLayer)
                
                previewLayer?.addSublayer(speedometerLayer)
                
                previewLayer?.addSublayer(concentrationLayer)
                
                turnView = UIImageView(image: UIImage(named: "turn_right"))
                turnView.frame = CGRectMake(110, 260, 32, 32)
                
                previewLayer?.addSublayer(turnView.layer)
                
                replicatorLayer.addSublayer(previewLayer!)
                
                self.view.layer.addSublayer(replicatorLayer)
                captureSession?.startRunning()
            }
        }
    }
    
}