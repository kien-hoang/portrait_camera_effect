//
//  ViewController.swift
//  PortraitCameraEffect
//
//  Created by Bradley Hoang on 15/05/2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!

    private var session: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    
    private var originalImage: UIImage?
    private var blurringImage: UIImage?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupCustomCamera()
    }

    /// Setting up custom camera
    private func setupCustomCamera() {
        /// Select input device
        guard let backCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else {
                print("Unable to access back camera!")
                return
        }
        
        /// Prepare input and output
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            session = AVCaptureSession()
            session!.beginConfiguration()
            session!.sessionPreset = .photo
            session!.addInput(input)
            
            capturePhotoOutput = AVCapturePhotoOutput()
            session!.addOutput(capturePhotoOutput!)
            session!.commitConfiguration()
            // really important because we need to get the depth map after captured image
            capturePhotoOutput!.isDepthDataDeliveryEnabled = true
            
            setupLivePreview()
            
            session!.startRunning()
            
        } catch let error {
            print(error)
        }
    }
    
    /// Set up live preview to show custom camera
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
        videoPreviewLayer!.videoGravity = .resizeAspect
        videoPreviewLayer!.connection?.videoOrientation = .portrait
        videoPreviewLayer!.frame = view.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer!)
    }
    
    @IBAction func onTapTakePhoto(_ sender: Any) {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }

        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isDepthDataDeliveryEnabled = true

        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func onTapShowPhoto(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CapturedImageVC") as! CapturedImageVC
        vc.originalImage = originalImage
        vc.blurringImage = blurringImage
        present(vc, animated: true)
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print(photo.depthData)
        
        guard let imageData = photo.fileDataRepresentation(),
              let mainImage = CIImage(data: imageData),
              
              // Get the depth map
              let disparityImage = CIImage(data: imageData, options: [.auxiliaryDisparity: true]),
              
              // Merge 2 image: original image and depth map
              let filter = CIFilter(name: "CIDepthBlurEffect",
                                    parameters: [kCIInputImageKey : mainImage,
                                        kCIInputDisparityImageKey : disparityImage]),
              
              // Got the image which has blur effect like PORTRAIT native camera
              let outputImage = filter.outputImage else { return }
        
        let resultImage = UIImage(ciImage: outputImage.oriented(.right))
        captureImageView.image = resultImage
        
        // Get latest capture image
        blurringImage = resultImage
        originalImage = UIImage(data: photo.fileDataRepresentation()!)
    }
}
