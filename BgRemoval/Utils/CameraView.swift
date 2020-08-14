//
//  CameraViewController.swift
//  SwiftUI-CameraApp
//
//  Created by Gaspard Rosay on 28.01.20.
//  Copyright © 2020 Gaspard Rosay. All rights reserved.
//

import SwiftUI
import UIKit
import AVFoundation


struct CameraView: View {
    
    @State var photoAlginment: Alignment = .bottomLeading
    @State private var image: UIImage?
    @State private var didTapCapture: Bool = false
    
    var body: some View {
        ZStack(alignment: self.photoAlginment) {
            Button(action: {
                self.didTapCapture.toggle()
            }) {
                CameraViewController(image: self.$image, didTapCapture: $didTapCapture)
            }
            
            if image != nil {
                Image(uiImage: self.image!)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .shadow(radius: 30)
                    .border(Color.white, width: 4)
                    .padding()
            }
        }
        
    }
    
    
    struct CameraViewController: UIViewControllerRepresentable {
        
        @Environment(\.presentationMode) var presentationMode
        @Binding var image: UIImage?
        @Binding var didTapCapture: Bool
        
        func makeUIViewController(context: Context) -> CameraController {
            let controller = CameraController()
            controller.delegate = context.coordinator
            return controller
        }
        
        func updateUIViewController(_ cameraViewController: CameraController, context: Context) {
            
            if(self.didTapCapture) {
                cameraViewController.didTapRecord()
            }
        }
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
            let parent: CameraViewController
            
            init(_ parent: CameraViewController) {
                self.parent = parent
            }
            
            func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
                
                parent.didTapCapture = false
                
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
                    parent.image = rotatedImage
                }
                parent.presentationMode.wrappedValue.dismiss()
            }
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
            
            self.currentCamera = self.backCamera
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
