//
//  ScannerViewController.swift
//  QRSacnner
//
//  Created by Rahul on 21/12/20.
//

import UIKit
import AVFoundation

protocol ScannerDelegate: class {
    func didCompleteScanning(_ code: String, _ sender: UIViewController)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var scanBackgroundView: UIView!
    
    @IBOutlet weak var guidingLabel: UILabel!
    @IBOutlet weak var guidingView: UIView!
    weak var delegate: ScannerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = scanBackgroundView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scanBackgroundView.layer.addSublayer(previewLayer)
        
        guidingView.layer.borderWidth = 2.0
        guidingView.layer.borderColor = UIColor.red.cgColor
        guidingView.layer.cornerRadius = 8
        
        scanBackgroundView.layer.addSublayer(guidingView.layer)
        scanBackgroundView.layer.addSublayer(guidingLabel.layer)
        
        metadataOutput.rectOfInterest = guidingView.frame

        metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: guidingView.frame)
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

    }

    func found(code: String) {
        guidingView.layer.borderColor = UIColor.green.cgColor
        
       // delegate.didCompleteScanning(code, self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
