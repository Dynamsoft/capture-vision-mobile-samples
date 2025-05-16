/*
 * This is the sample of Dynamsoft Document Normalizer.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class CameraViewController: UIViewController {
    
    let cvr = CaptureVisionRouter()
    let dce = CameraEnhancer()
    let cameraView = CameraView()
    var isButtonSelected = false
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Capture", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Boundary Detecting"
        setLicense()
        setupDCV()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
        cvr.startCapturing(PresetTemplate.detectAndNormalizeDocument.rawValue) { isSuccess, error in
            if let error = error, !isSuccess {
                DispatchQueue.main.async {
                    self.displayError(message: error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dce.close()
        dce.clearBuffer()
        cvr.stopCapturing()
    }
}

extension CameraViewController {
    
    private func setupDCV() {
        dce.cameraView = cameraView
        // Set the camera enhancer as the input.
        try! cvr.setInput(dce)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
        // Enable multi-frame result cross filter to receive more accurate boundaries.
        let filter = MultiFrameResultCrossFilter()
        filter.enableResultCrossVerification(.deskewedImage, isEnabled: true)
        cvr.addResultFilter(filter)
    }
    
    private func setupLayout() {
        view.insertSubview(cameraView, at: 0)
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    @objc func buttonTapped() {
        isButtonSelected = true
    }
    
    private func displayError(message: String) {
        let shadowView = UIView()
        shadowView.backgroundColor = .darkGray.withAlphaComponent(0.5)
        view.addSubview(shadowView)
        
        let imageView = UIImageView(image: UIImage(named: "attention"))
        shadowView.addSubview(imageView)
        
        let label = UILabel()
        label.text = message
        label.numberOfLines = 0
        label.textColor = .white
        shadowView.addSubview(label)
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            shadowView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            shadowView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 50),
            shadowView.heightAnchor.constraint(equalTo: label.heightAnchor, constant: 20),
            
            imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: shadowView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            
            label.centerYAnchor.constraint(equalTo: shadowView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: -10),
        ])
    }
}

extension CameraViewController: CapturedResultReceiver {
    func onProcessedDocumentResultReceived(_ result: ProcessedDocumentResult) {
        if let item = result.deskewedImageResultItems?.first {
            if item.crossVerificationStatus == .passed || isButtonSelected {
                guard let data = cvr.getIntermediateResultManager().getOriginalImage(result.originalImageHashId) else { return }
                isButtonSelected = false
                cvr.stopCapturing()
                DispatchQueue.main.async {
                    let vc = ResultViewController()
                    vc.data = data
                    vc.quad = item.sourceDeskewQuad
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension CameraViewController: LicenseVerificationListener {
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=ddn&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
}
