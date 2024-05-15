/*
 * This is the sample of Dynamsoft Capture Vision Router.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionRouter
import DynamsoftCodeParser
import DynamsoftBarcodeReader
import DynamsoftCameraEnhancer

class ViewController: UIViewController, CapturedResultReceiver {

    private var cvr: CaptureVisionRouter!
    private var dce: CameraEnhancer!
    private var dceView: CameraView!
    
    private var driveLicenseTemplate = "ReadPDF417"
    private var isExistRecognizedText = false
    
    private lazy var resultView: UITextView = {
        let left = 0.0
        let width = self.view.bounds.size.width
        let height = self.view.bounds.size.height / 2.5
        let top = self.view.bounds.size.height - height
        
        let resultView = UITextView(frame: CGRect(x: left, y: top , width: width, height: height))
        resultView.layer.backgroundColor = UIColor.clear.cgColor
        resultView.layoutManager.allowsNonContiguousLayout = false
        resultView.isUserInteractionEnabled = false
        resultView.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        resultView.textColor = UIColor.white
        resultView.textAlignment = .center
        return resultView
    }()
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "DriversLicenseScanner"
        
        configureCVR()
        configureDCE()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 59.003 / 255.0, green: 61.9991 / 255.0, blue: 69.0028 / 255.0, alpha: 1)
        
        dce.open()
        cvr.startCapturing(driveLicenseTemplate) {
            [unowned self] isSuccess, error in
            if let error = error {
                self.displayError(msg: error.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dce.close()
        cvr.stopCapturing()
        dce.clearBuffer()
    }
}

// MARK: - Config.
extension ViewController {
    private func configureCVR() -> Void {
        cvr = CaptureVisionRouter()
        cvr.addResultReceiver(self)
        
        // Init settings.
        let driverLicenseTemplatePath = "drivers-license.json"
        try? cvr.initSettingsFromFile(driverLicenseTemplatePath)
    }
    
    private func configureDCE() -> Void {
        dceView = CameraView(frame: CGRect(x: 0, y: kNavigationBarFullHeight, width: kScreenWidth, height: kScreenHeight - kNavigationBarFullHeight))
        dceView.scanLaserVisible = true
        self.view.addSubview(dceView)
        
        let dbrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DBR.rawValue)
        dbrDrawingLayer?.visible = true
        dce = CameraEnhancer(view: dceView)
        
        // CVR link DCE.
        try? cvr.setInput(dce)
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(resultView)
    }
}

// MARK: - CapturedResultReceiver
extension ViewController {
    func onDecodedBarcodesReceived(_ result: DecodedBarcodesResult) {
        guard let items = result.items else {
            isExistRecognizedText = false
            return
        }

        isExistRecognizedText = true
        Feedback.vibrate()
        Feedback.beep()
        
        DispatchQueue.main.async{
            self.resultView.text = items.first!.text
        }
    }

    func onParsedResultsReceived(_ result: ParsedResult) {
        guard let items = result.items else {
            if isExistRecognizedText == true {
                DispatchQueue.main.async {
                    self.resultView.text = parseFailedTip + self.resultView.text
                }
            }
            return
        }
        
        let (isLegal, tip) = determineWhetherParsedItemIsLegal(parsedItem: items.first!)
        
        if isLegal == true {
            cvr.stopCapturing()
            dce.clearBuffer()
        }
        
        DispatchQueue.main.async {
            if isLegal == true {
                self.resultView.text = self.resultView.text.replacingOccurrences(of: parseFailedTip, with: "")
                let resultVC = DriverLicenseResultViewController()
                resultVC.driverLicenseResultItem = items.first!
                self.navigationController?.pushViewController(resultVC, animated: true)
            } else {
                self.resultView.text = tip
            }
        }
    }
}

// MARK: - General methods.
extension ViewController {
    func determineWhetherParsedItemIsLegal(parsedItem: ParsedResultItem) -> (Bool, String) {
        let allKeys = parsedItem.parsedFields.keys
        var isLegal = false
        var tip = ""
        switch parsedItem.codeType {
        case DriverLicenseType.AAMVA_DL_ID.rawValue:
            if (allKeys.contains("lastName") ||
                allKeys.contains("givenName") ||
                allKeys.contains("firstName") ||
                allKeys.contains("fullName")) &&
                allKeys.contains("licenseNumber") {
                isLegal = true
            } else {
                isLegal = false
                tip = parsedContentDeficiencyTip
            }
            break
        case DriverLicenseType.AAMVA_DL_ID_WITH_MAG_STRIPE.rawValue:
            if  allKeys.contains("name") &&
                allKeys.contains("DLorID_Number") {
                isLegal = true
            } else {
                isLegal = false
                tip = parsedContentDeficiencyTip
            }
            break
        case DriverLicenseType.SOUTH_AFRICA_DL.rawValue:
            if  allKeys.contains("surname") &&
                allKeys.contains("idNumber") {
                isLegal = true
            } else {
                isLegal = false
                tip = parsedContentDeficiencyTip
            }
            break
        default:
            break
        }
        return (isLegal, tip)
    }
    
    private func displayError(_ title: String = "", msg: String, _ acTitle: String = "OK", completion: ConfirmCompletion? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
