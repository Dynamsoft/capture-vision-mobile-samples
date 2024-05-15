/*
 * This is the sample of Dynamsoft Capture Vision Router.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionRouter
import DynamsoftCodeParser
import DynamsoftBarcodeReader
import DynamsoftLabelRecognizer
import DynamsoftCameraEnhancer
import DynamsoftUtility

class ViewController: UIViewController, CapturedResultReceiver {

    private var cvr: CaptureVisionRouter!
    private var dce: CameraEnhancer!
    private var dceView: CameraView!
    private var resultFilter: MultiFrameResultCrossFilter!
    private let codeParser = CodeParser()
    
    private var currentVINPattern: VINPattern = .barcode
    private var currentVINTemplate: VINCustomizedTemplate = .barcode
    private var isExistRecognizedText = false
    
    private lazy var resultView: UITextView = {
        let left = 0.0
        let width = self.view.bounds.size.width
        let height = self.view.bounds.size.height / 4.0
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
    
    lazy var patternView: PatternView = {
        let view = PatternView(frame: CGRect(x: 0, y: kNavigationBarFullHeight, width: kCellWidth, height: PatternView.patternHeight()), selectedPattern: currentVINPattern)
        return view
    }()
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.center = self.view.center
        indicator.style = .medium
        indicator.color = .white
        return indicator
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "VIN Scanner"
        
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
        switchTemplate(with: currentVINPattern)
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
        let vinTemplatePath = "vin.json"
        try? cvr.initSettingsFromFile(vinTemplatePath)
        
        // Add filter.
        resultFilter = MultiFrameResultCrossFilter()
        resultFilter.enableResultCrossVerification(.barcode, isEnabled: true)
        resultFilter.enableResultCrossVerification(.textLine, isEnabled: true)
        cvr.addResultFilter(resultFilter)
    }
    
    private func configureDCE() -> Void {
        dceView = CameraView(frame: CGRect(x: 0, y: kNavigationBarFullHeight, width: kScreenWidth, height: kScreenHeight - kNavigationBarFullHeight))
        dceView.scanLaserVisible = true
        self.view.addSubview(dceView)
        
        let dbrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DBR.rawValue)
        dbrDrawingLayer?.visible = true
        let dlrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DLR.rawValue)
        dlrDrawingLayer?.visible = true
        
        dce = CameraEnhancer(view: dceView)
        
        // ScanRegion.
        let region = Rect()
        region.top = 0.4
        region.bottom = 0.6
        region.left = 0.1
        region.right = 0.9
        region.measuredInPercentage = true
        try? dce.setScanRegion(region)
        
        // CVR link DCE.
        try? cvr.setInput(dce)
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(resultView)
        self.view.addSubview(patternView)
        self.view.addSubview(loadingIndicator)
        
        self.patternView.patternSelectedCompletion = {
            [unowned self] pattern in
            DispatchQueue.main.async {
                self.currentVINPattern = pattern
                self.switchTemplate(with: pattern)
            }
        }
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
    
    func onRecognizedTextLinesReceived(_ result: RecognizedTextLinesResult) {
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
        DispatchQueue.main.async {
            self.resultView.text = self.resultView.text.replacingOccurrences(of: parseFailedTip, with: "")
        }
        
        cvr.stopCapturing()
        dce.clearBuffer()
        DispatchQueue.main.async{
            let resultVC = VINResultViewController()
            resultVC.vinResultItem = items.first!
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}

// MARK: - General methods.
extension ViewController {
    private func switchTemplate(with pattern: VINPattern) -> Void {
        self.loadingIndicator.startAnimating()
        cvr.stopCapturing()
        dce.clearBuffer()
        
        switch pattern {
        case .barcode:
            currentVINTemplate = .barcode
            dce.disableEnhancedFeatures(.frameFilter)
            break
        case .text:
            currentVINTemplate = .text
            dce.enableEnhancedFeatures(.frameFilter)
            break
        }
        
        cvr.startCapturing(currentVINTemplate.rawValue) {
            [unowned self] isSuccess, error in
            if let error = error {
                self.displayError(msg: error.localizedDescription)
            }
        }
        self.loadingIndicator.stopAnimating()
    }
    
    private func displayError(_ title: String = "", msg: String, _ acTitle: String = "OK", completion: ConfirmCompletion? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
