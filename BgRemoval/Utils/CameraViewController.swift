//
//  CameraViewController.swift
//  BgRemoval
//
//  Created by Marco@GaspardBruno on 28/08/2020.
//  Copyright © 2020 Marco João. All rights reserved.
//

import SwiftUI
import UIKit
import AVFoundation


struct CameraView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var picture: UIImage?
    @Binding var takePicture: Bool
    
    func makeUIViewController(context: Context) -> CameraController {
        let controller = CameraController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CameraController, context: Context) {
        
        if(self.takePicture) {
            cameraViewController.didTapRecord()
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            
            parent.takePicture = false
            
            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
                var rotateDegree: Float = 0
                switch UIDevice.current.orientation {
                case .portrait:
                    rotateDegree = 0
                case .portraitUpsideDown:
                    rotateDegree = .pi
                case .landscapeLeft:
                    rotateDegree = .pi * 1.5
                case .landscapeRight:
                    rotateDegree = .pi / 2
                default:
                    rotateDegree = 0
                }
                
                let rotatedImage = image.rotate(radians: rotateDegree)
                parent.picture = rotatedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    class CameraController: UIViewController {
        
        var image: UIImage?
        
        var captureSession = AVCaptureSession()
        var backCamera: AVCaptureDevice?
        var frontCamera: AVCaptureDevice?
        var currentCamera: AVCaptureDevice?
        var photoOutput: AVCapturePhotoOutput?
        var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
        
        var delegate: AVCapturePhotoCaptureDelegate?
        
        func didTapRecord() {
            
            let settings = AVCapturePhotoSettings()
            photoOutput?.capturePhoto(with: settings, delegate: delegate!)
            
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setup()
        }
        func setup() {
            setupCaptureSession()
            setupDevice()
            setupInputOutput()
            setupPreviewLayer()
            startRunningCaptureSession()
        }
        func setupCaptureSession() {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        
        func setupDevice() {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                          mediaType: AVMediaType.video,
                                                                          position: AVCaptureDevice.Position.unspecified)
            for device in deviceDiscoverySession.devices {
                
                switch device.position {
                case AVCaptureDevice.Position.front:
                    self.frontCamera = device
                case AVCaptureDevice.Position.back:
                    self.backCamera = device
                default:
                    break
                }
            }
            
            self.currentCamera = self.frontCamera
        }
        
        
        func setupInputOutput() {
            do {
                
                let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
                captureSession.addInput(captureDeviceInput)
                photoOutput = AVCapturePhotoOutput()
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                captureSession.addOutput(photoOutput!)
                
            } catch {
                print(error)
            }
            
        }
        func setupPreviewLayer()
        {
            self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            self.cameraPreviewLayer?.frame = self.view.frame
            self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            
        }
        func startRunningCaptureSession(){
            captureSession.startRunning()
        }
    }
}
