//
//  ViewController.swift
//  learnCamera
//
//  Created by huchunbo on 15/12/12.
//  Copyright © 2015年 Bijiabo. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    
    var session: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCaptrueObservers()
        addTapGestureRecognizerToPreview()
    }
    
    deinit {
        removeCaptureObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setupViews()
        setupCaptureSession()
        setupPreview()
        
        // check devices
        //checkDevices(devices)
    }
    
    private func setupViews() {
        let captrueButtonLayer = captureButton.layer
        captrueButtonLayer.cornerRadius = captrueButtonLayer.frame.size.width/2.0
    }
    
    private func setupCaptureSession() {
        session = AVCaptureSession()
        
        // configuring session
        session.beginConfiguration()
        
        if session.canSetSessionPreset(AVCaptureSessionPresetHigh) {
            session.sessionPreset = AVCaptureSessionPresetHigh
        } else {
            // Handle the failure.
            print("Device does not support set AVCaptureSession preset to be AVCaptureSessionPresetLow")
        }
        
        // add inputs
        var cameraInput: AVCaptureDeviceInput?
        if let camera = camera_back {
            if let input = try? AVCaptureDeviceInput(device: camera) {
                cameraInput = input
                currentCameraDevice = camera
            }
        } else if let camera = camera_font {
            if let input = try? AVCaptureDeviceInput(device: camera) {
                cameraInput = input
                currentCameraDevice = camera
            }
        }
        
        if let cameraInput = cameraInput {
            session.addInput(cameraInput)
        }
        
        // add outputs
        let movieOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        } else {
            print("capture session does not support add AVCaptureMoviceFileOutput.")
        }
        
        session.commitConfiguration()
        
        // start data flow by sending the session a startRunning message
        session.startRunning()
    }
    
    private func setupPreview() {
        let capturePreviewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        capturePreviewLayer.frame = view.bounds
        previewView.layer.addSublayer(capturePreviewLayer)
    }

    // MARK: - session observers
    private func addCaptrueObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        // capture session observers
        notificationCenter.addObserver(
            self,
            selector: Selector("captureSessionRunTimeError:"),
            name: AVCaptureSessionRuntimeErrorNotification,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: Selector("captureSessionInterrupted:"),
            name: AVCaptureSessionWasInterruptedNotification,
            object: nil)
        // capture device observers
        notificationCenter.addObserver(
            self,
            selector: Selector("captureDeviceWasConnected:"),
            name: AVCaptureDeviceWasConnectedNotification,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: Selector("captureDeviceWasDisConnected:"),
            name: AVCaptureDeviceWasDisconnectedNotification,
            object: nil)
    }
    
    private func removeCaptureObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        func removeObserverByName(name: String) {
            notificationCenter.removeObserver(self, name: name, object: nil)
        }
        func removeObserverByNames(names: [String]) {
            for name in names {
                removeObserverByName(name)
            }
        }
        
        // capture session observers
        removeObserverByNames([
            AVCaptureSessionRuntimeErrorNotification,
            AVCaptureSessionWasInterruptedNotification
            ])
        // capture device observers
        removeObserverByNames([
            AVCaptureDeviceWasConnectedNotification,
            AVCaptureDeviceWasDisconnectedNotification
            ])
    }
    
    func captureSessionRunTimeError(notification: NSNotification) {
        
    }
    
    func captureSessionInterrupted(notification: NSNotification) {
        
    }
    
    func captureDeviceWasConnected(notification: NSNotification) {
        
    }
    
    func captureDeviceWasDisConnected(notification: NSNotification) {
        
    }
    
    // MARK: - device functions
    var devices: [AnyObject]! {
        return AVCaptureDevice.devices()
    }
    
    var cameraDevices: [AVCaptureDevice] {
        guard let deivceList = devices as? [AVCaptureDevice] else {return [AVCaptureDevice]()}

        var cameras = [AVCaptureDevice]()
        
        for device in deivceList {
            if device.hasMediaType(AVMediaTypeVideo) {
                cameras.append(device)
            }
        }
        return cameras
    }
    
    var currentCameraDevice: AVCaptureDevice?
    
    func checkDevices(devices: [AnyObject]) {
        guard let deivceList = devices as? [AVCaptureDevice] else {return}
        
        for device in deivceList {
            print("\nDevice name: \(device.localizedName)")
            print("modelID: \(device.modelID)")
            print("uniqueID: \(device.uniqueID)")
            
            if device.hasMediaType(AVMediaTypeVideo) {
                // show if has torch
                if device.hasTorch {
                    print("has torch")
                } else {
                    print("don't has torch")
                }
                
                // show position
                if device.position == AVCaptureDevicePosition.Back {
                    print("Device position : back")
                } else {
                    print("Device position : front")
                }
            } else if device.hasMediaType(AVMediaTypeAudio) {
                print(device.localizedName)
            }
        }
    }
    
    
    var camera_back: AVCaptureDevice? {
        return cameraByPosition(AVCaptureDevicePosition.Back)
    }
    var camera_font: AVCaptureDevice? {
        return cameraByPosition(AVCaptureDevicePosition.Front)
    }
    
    private func cameraByPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        guard let deivceList = devices as? [AVCaptureDevice] else {return nil}
        
        for device in deivceList {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == position {
                    return device
                }
            }
        }
        return nil
    }
    
    // MARK: - user actions
    private func addTapGestureRecognizerToPreview() {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: Selector("userTappedPreview:")
        )
        previewView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func userTappedPreview(gesture: UITapGestureRecognizer) {
        guard let gestureView = gesture.view else {return}
        
        let locationInView = gesture.locationInView(gestureView)
        let focusPoint: CGPoint = CGPoint(
            x: locationInView.x/gestureView.frame.size.width , y:
            locationInView.y/gestureView.frame.size.width
        )
        setDeviceFocusPoint(pointInPercentage: focusPoint, pointInCGFlot: locationInView)
    }
    
    private func setDeviceFocusPoint(pointInPercentage pointInPercentage: CGPoint, pointInCGFlot: CGPoint) {
        guard let currentDevice = currentCameraDevice else {return}
        
        if currentDevice.focusPointOfInterestSupported == true {
            do {
                try currentDevice.lockForConfiguration()
                currentDevice.focusPointOfInterest = pointInPercentage
                currentDevice.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                currentDevice.unlockForConfiguration()
            } catch {
                return
            }
            // remove previous focus vision tipc
            previewView.viewWithTag(2048)?.removeFromSuperview()
            // add focus vision tip
            let visionTipViewWidth_half: CGFloat = 60.0/2.0
            let visionTipView: UIView = UIView(frame:
                CGRect(
                    x: pointInCGFlot.x-visionTipViewWidth_half,
                    y: pointInCGFlot.y-visionTipViewWidth_half,
                    width: visionTipViewWidth_half*2.0,
                    height: visionTipViewWidth_half*2.0
                )
            )
            visionTipView.tag = 2048
            // setup visionTipView's style
            visionTipView.backgroundColor = UIColor.clearColor()
            visionTipView.layer.borderColor = UIColor(red:0.2, green:0.66, blue:0.9, alpha:1).CGColor
            visionTipView.layer.borderWidth = 1.0
            visionTipView.alpha = 0
            // disable user tap visionTipView
            visionTipView.userInteractionEnabled = false
            previewView.addSubview(visionTipView)
            // setup visionTipView's animation
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    visionTipView.alpha = 1.0
                },
                completion: { (finished) -> Void in
                    if finished {
                        UIView.animateWithDuration(0.5,
                            animations: { () -> Void in
                                visionTipView.alpha = 0
                            },
                            completion: { (finished) -> Void in
                                if finished {
                                    visionTipView.removeFromSuperview()
                                }
                        })
                    }
                }
            )
        }
    }
    
    @IBAction func tapSwitchCameraButton(sender: AnyObject) {
        if cameraDevices.count < 2 {return}
        
        var previousCameraInput: AVCaptureDeviceInput?
        
        for input in session.inputs {
            guard let input = input as? AVCaptureDeviceInput else {continue}
            if input.device == currentCameraDevice {
                previousCameraInput = input
                break
            }
        }
        
        for camera in cameraDevices {
            if currentCameraDevice != camera {
                if let newInput = try? AVCaptureDeviceInput(device: camera)
                {
                    session.beginConfiguration()
                    
                    if let previousCameraInput = previousCameraInput {
                        session.removeInput(previousCameraInput)
                    }
                    
                    if session.canAddInput(newInput) {
                        session.addInput(newInput)
                        currentCameraDevice = camera
                    } else {
                        session.addInput(previousCameraInput)
                    }
                    
                    session.commitConfiguration()
                    break
                }
            }
        }
    }
    
    
}

