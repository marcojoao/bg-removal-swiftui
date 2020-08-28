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
    
    @Binding var takePicture: Bool
    @Binding var useBackCamera: Bool
    var onResult: ((UIImage) -> Void)
    
    func makeUIViewController(context: Context) -> CameraController {
        let controller = CameraController()
        controller.photoCaptureDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CameraController, context: Context) {
        
        if self.takePicture {
            cameraViewController.didTapTakePicture()
            
        }
        
        let updatePostion = cameraViewController.useBackCamera != self.useBackCamera
        if updatePostion == true {
            cameraViewController.didToggleChangeCamera()
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
                
                if let safeImage = image.rotate(radians: rotateDegree) {
                    parent.onResult(safeImage)
                }
            }
            
        }
    }
    
    class CameraController: UIViewController {

        var image: UIImage?
        
        var captureSession = AVCaptureSession()
        var currentCamera: AVCaptureDevice?
        var photoOutput: AVCapturePhotoOutput?
        var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
        
        var photoCaptureDelegate: AVCapturePhotoCaptureDelegate?
        var useBackCamera: Bool = true

        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            if captureSession.isRunning == false {
                setup()
            }
            
        }
        
        fileprivate func didTapTakePicture() {
            let settings = AVCapturePhotoSettings()
            photoOutput?.capturePhoto(with: settings, delegate: photoCaptureDelegate!)
        }

        fileprivate func didToggleChangeCamera() {
            self.useBackCamera.toggle()
            
            let cameraPosition: AVCaptureDevice.Position = self.useBackCamera ? .back : .front
            guard let backCamera = self.getCamera(position: cameraPosition) else {
                print("Unable to access back camera!")
                return
            }
            
            do {
                self.captureSession.beginConfiguration()
                let input = try AVCaptureDeviceInput(device: backCamera)
                
                for i in captureSession.inputs {
                    captureSession.removeInput(i)
                }
                
                if captureSession.canAddInput(input) {
                    
                    captureSession.addInput(input)
                    
                }
                self.captureSession.commitConfiguration()
            } catch let error {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }
        }

        fileprivate func setup() {
            setupCaptureSession()
            setupDevice()
            if setupInputOutput() {
                setupPreviewLayer()
                startRunningCaptureSession()
            }

        }
        
        fileprivate func setupCaptureSession() {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        
        fileprivate func setupDevice() {
            self.currentCamera =  getCamera(position: .back)
        }
        
        fileprivate func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
            
            for i in captureSession.inputs {
                captureSession.removeInput(i)
            }
            
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera,
                                                                         .builtInDualCamera,
                                                                         .builtInWideAngleCamera],
                                                           mediaType: .video,
                                                           position: position)
            for de in devices.devices {
                let deviceConverted = de
                if deviceConverted.position == position {
                    self.useBackCamera = position == .back
                    return deviceConverted
                }
            }
            return nil
        }
        
        
        fileprivate func setupInputOutput() -> Bool {
            do {
                
                guard let safeCurrentCamera = currentCamera else {
                    print("Unable to access back camera!")
                    return false
                }
                
                let captureDeviceInput = try AVCaptureDeviceInput(device: safeCurrentCamera)
                for input in captureSession.inputs {
                    captureSession.removeInput(input);
                }
                captureSession.addInput(captureDeviceInput)
                photoOutput = AVCapturePhotoOutput()
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                for output in captureSession.outputs {
                    captureSession.removeOutput(output);
                }
                captureSession.addOutput(photoOutput!)
                
            } catch {
                print(error)
                return false
            }
            return true
        }
        
        fileprivate func setupPreviewLayer()
        {
            self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            self.cameraPreviewLayer?.frame = self.view.frame
            self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
            
        }
        
        fileprivate func startRunningCaptureSession(){
            captureSession.startRunning()
        }
    }
}
