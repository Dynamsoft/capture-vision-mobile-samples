/*
 * This is the sample of Dynamsoft Capture Vision.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class ViewController: UIViewController {

    var cameraView = CameraView()
    let dce = CameraEnhancer()
    let cvr = CaptureVisionRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ID Extraction"
        setLicense()
        setupDCV()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
        // Start capturing when the view will appear. If success, you will receive results in the CapturedResultReceiver.
        cvr.startCapturing("ReadID") { isSuccess, error in
            if (!isSuccess) {
                if let error = error {
                    self.showResult("Error", error.localizedDescription)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
    }

    func setupDCV() {
        view.insertSubview(cameraView, at: 0)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        dce.cameraView = cameraView
        // Set the camera enhancer as the input.
        try! cvr.setInput(dce)
        // Add CapturedResultReceiver to receive the result callback when a video frame is processed.
        cvr.addResultReceiver(self)
        try! cvr.initSettingsFromFile("read_id.json")
        let filter = MultiFrameResultCrossFilter()
        filter.enableResultCrossVerification(.textLine, isEnabled: true)
        cvr.addResultFilter(filter)
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: CapturedResultReceiver {
    func onCapturedResultReceived(_ result: CapturedResult) {
        guard let item = result.parsedResult?.items?.first else { return }
        if let mrzData = MRZData.fromParsedResultItem(item) {
            DispatchQueue.main.async {
                let vc = ResultViewController()
                vc.mrzData = mrzData

                self.navigationController?.pushViewController(
                    vc,
                    animated: true
                )
            }
            
        } else if let driverLicenseData = DriverLicenseData.fromParsedResultItem(item) {
            DispatchQueue.main.async {
                let vc = ResultViewController()
                vc.driverLicenseData = driverLicenseData

                self.navigationController?.pushViewController(
                    vc,
                    animated: true
                )
            }
        }
    }
}

// MARK: LicenseVerificationListener
extension ViewController: LicenseVerificationListener {
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=samples&package=ios
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
