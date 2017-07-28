//
//  TWCameraView.swift
//
//  Copyright (c) 2016 Tom Weightman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit
import AVFoundation

public protocol TWCameraViewDelegate: class {
    func cameraViewDidCaptureImage(image: UIImage, cameraView: TWCameraView)
    func cameraViewDidFailToCaptureImage(error: Error, cameraView: TWCameraView)
}

public class TWCameraView: UIView {
    
    //MARK: Types
    public enum CameraType: String, Hashable, Equatable {
        
        case front = "front"
        case back = "back"
        
        public var hashValue: Int {
            return self.rawValue.hashValue
        }
        
    }
    
    //MARK: Public vars
    public weak var delegate: TWCameraViewDelegate?
    
    public var focusPoint = CGPoint(x: 0.5, y: 0.5) {
        
        didSet {
            
            try? updateForFocusPoint()
            
        }
        
    }
    
    public var cameraType: CameraType = .back {
        
        didSet {
            
            if (self.cameraType != oldValue) {
                updateForCameraType()
            }
            
        }
        
    }
    
    public var authorizedForCapture: Bool {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
    }
    
    //MARK: Camera capture
    fileprivate var frontCameraDeviceInput: AVCaptureDeviceInput?
    fileprivate var backCameraDeviceInput: AVCaptureDeviceInput?
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var photoOutput: AVCapturePhotoOutput?
    
    //MARK: UI
    fileprivate var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    //MARK: Functions
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        
        if self.authorizedForCapture {
            setupCaptureSession()
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if let cameraPreviewLayer = self.cameraPreviewLayer {
            
            cameraPreviewLayer.frame = self.bounds
            
            //Set orientation on connection
            if (cameraPreviewLayer.connection.isVideoOrientationSupported) {
                
                switch UIDevice.current.orientation {
                case .portrait, .portraitUpsideDown:
                    cameraPreviewLayer.connection.videoOrientation = .portrait
                case .landscapeRight:
                    cameraPreviewLayer.connection.videoOrientation = .landscapeLeft
                case .landscapeLeft:
                    cameraPreviewLayer.connection.videoOrientation = .landscapeRight
                default:
                    cameraPreviewLayer.connection.videoOrientation = .portrait
                }
                
            }
            
        }
        
    }
    
    //MARK: Capture session
    
    private func setupCaptureSession() {
        
        //Camera devices
        guard let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) else { return }
        guard let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) else { return }
        
        guard let frontCameraDeviceInput = try? AVCaptureDeviceInput(device: frontCameraDevice) else { return }
        guard let backCameraDeviceInput = try? AVCaptureDeviceInput(device: backCameraDevice) else { return }
        
        self.frontCameraDeviceInput = frontCameraDeviceInput
        self.backCameraDeviceInput = backCameraDeviceInput
        
        //Capture session
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        updateForCameraType()
        try? updateForFocusPoint()
        
        //Photo output
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput?.isHighResolutionCaptureEnabled = true
        self.captureSession?.addOutput(self.photoOutput!)
        
        //UI
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        self.cameraPreviewLayer?.frame = self.bounds
        self.layer.addSublayer(self.cameraPreviewLayer!)
        
    }
    
    private func updateForCameraType() {
        
        //Add/remove inputs from capture session as appropriate
        
        guard let captureSession = self.captureSession else { return }
        guard let frontCameraDeviceInput = self.frontCameraDeviceInput else { return }
        guard let backCameraDeviceInput = self.backCameraDeviceInput else { return }
        
        switch self.cameraType {
        case .front:
            
            if !captureSession.inputs.isEmpty {
                self.captureSession?.removeInput(backCameraDeviceInput)
            }
            
            self.captureSession?.addInput(frontCameraDeviceInput)
            
        case .back:
            
            if !captureSession.inputs.isEmpty {
                self.captureSession?.removeInput(frontCameraDeviceInput)
            }
            
            self.captureSession?.addInput(backCameraDeviceInput)
            
        }
        
    }
    
    private func updateForFocusPoint() throws {
        
        guard let frontCameraDeviceInput = self.frontCameraDeviceInput else { return }
        guard let backCameraDeviceInput = self.backCameraDeviceInput else { return }
        
        try frontCameraDeviceInput.device.lockForConfiguration()
        try backCameraDeviceInput.device.lockForConfiguration()
        
        if frontCameraDeviceInput.device.isFocusPointOfInterestSupported {
            frontCameraDeviceInput.device.focusPointOfInterest = self.focusPoint
        }
        
        if backCameraDeviceInput.device.isFocusPointOfInterestSupported {
            backCameraDeviceInput.device.focusPointOfInterest = self.focusPoint
        }
        
        frontCameraDeviceInput.device.unlockForConfiguration()
        backCameraDeviceInput.device.unlockForConfiguration()
        
    }
    
    //MARK: Public camera control functions
    
    public func startPreview(requestPermissionIfNeeded: Bool = true) {
        
        if self.authorizedForCapture {
            
            //Setup if we need to. Normally happens on init, but not if we didn't have permission to start with.
            if self.captureSession == nil {
                setupCaptureSession()
            }
            
            self.captureSession?.startRunning()
            
        }
        else if requestPermissionIfNeeded {
            
            //We don't have permission. Request, then start running.
            requestCapturePermission() { [unowned self] permissionGranted in
                
                if permissionGranted {
                    self.captureSession?.startRunning()
                }
                
            }
            
        }
        
    }
    
    public func stopPreview() {
        
        self.captureSession?.stopRunning()
        
    }
    
    public func capturePhoto(imageStabilization: Bool = true, flashMode: AVCaptureFlashMode = .auto) {
        
        guard let photoOutput = self.photoOutput else { return }
        
        let captureSettings = AVCapturePhotoSettings(format: [ AVVideoCodecKey : AVVideoCodecJPEG ])
        
        if (self.cameraType == .back) {
            captureSettings.flashMode = flashMode
        }
        
        captureSettings.isAutoStillImageStabilizationEnabled = imageStabilization
        captureSettings.isHighResolutionPhotoEnabled = true
        
        photoOutput.capturePhoto(with: captureSettings, delegate: self)
        
    }
    
}

//MARK:- Permissions
fileprivate extension TWCameraView {
    
    fileprivate func requestCapturePermission(completion: @escaping (_ granted: Bool) -> Void) {
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { permissionGranted in
            
            //Call completion back on main thread
            DispatchQueue.main.async {
                
                completion(permissionGranted)
                
            }
            
        }
        
    }
    
}

//MARK:- AVCapturePhotoCaptureDelegate

extension TWCameraView: AVCapturePhotoCaptureDelegate {
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            self.delegate?.cameraViewDidFailToCaptureImage(error: error, cameraView: self)
            return
        }
        
        guard let photoSampleBuffer = photoSampleBuffer else { return }
        guard let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: nil) else { return }
        guard let jpegDataProvider = CGDataProvider(data: jpegData as CFData) else { return }
        guard let cgImage = CGImage(jpegDataProviderSource: jpegDataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.absoluteColorimetric) else { return }
        
        //Based on the orientation we set for the video capture, select the appropriate image orientation for output
        guard let captureOrientation = self.cameraPreviewLayer?.connection.videoOrientation else { return }
        let imageOrientation: UIImageOrientation
        switch captureOrientation {
        case .portrait:
            imageOrientation = .right
        case .portraitUpsideDown:
            imageOrientation = .left
        case .landscapeLeft:
            imageOrientation = .down
        case .landscapeRight:
            imageOrientation = .up
        }
        
        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: imageOrientation)
        
        self.delegate?.cameraViewDidCaptureImage(image: image, cameraView: self)
        
    }
    
}
