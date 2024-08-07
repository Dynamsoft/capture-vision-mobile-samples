import UIKit
import DynamsoftCaptureVisionRouter
import DynamsoftUtility
import DynamsoftLabelRecognizer
import DynamsoftCodeParser
import DynamsoftCameraEnhancer
import DynamsoftLicense

class CameraViewController: UIViewController {

    private var cvr: CaptureVisionRouter!
    private var dce: CameraEnhancer!
    private var dceView: CameraView!
    private var dlrDrawingLayer: DrawingLayer!
    private var resultFilter: MultiFrameResultCrossFilter!
    
    private var templateName = "ReadMRZ"
    private var mrzResultModel: MRZResultModel!
    private var isBeep: Bool = true
    
    private lazy var resultView: UITextView = {
        let left = 0.0
        let width = self.view.bounds.size.width
        let height = self.view.bounds.size.height / 3.0
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
    
    private lazy var beepButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "music-mute"), for: .normal)
        button.setImage(UIImage(named: "music"), for: .selected)
        button.addTarget(self, action: #selector(beepButtonTouchUp), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        button.backgroundColor = .clear
        button.isSelected = true
        return button
    }()
    
    // private lazy var scanLine: UIImageView = {
    //     let imageView = UIImageView(image: UIImage(named: "scan"))
    //     imageView.translatesAutoresizingMaskIntoConstraints = false
    //     imageView.sizeToFit()
    //     return imageView
    // }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = .init(red: 153 / 255.0, green: 153 / 255.0, blue: 153 / 255.0, alpha: 1.0)
        label.text = "Powered by Dynamsoft"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc func beepButtonTouchUp() {
        beepButton.isSelected = !beepButton.isSelected
        isBeep = beepButton.isSelected
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLicense()
        configureDCE()
        configureCVR()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false;
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 43 / 255.0, green: 43 / 255.0, blue: 43 / 255.0, alpha: 1)
        
        resetUI()
        dce.open()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cvr.startCapturing(templateName) {
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
    }

}

// MARK: LicenseVerificationListener
extension CameraViewController:LicenseVerificationListener {
    
    func setLicense() {
        // Initialize the license.
        // The license string here is a trial license. Note that network connection is required for this license to work.
        // You can request an extension via the following link: https://www.dynamsoft.com/customer/license/trialLicense?product=cvs&utm_source=samples&package=ios
        LicenseManager.initLicense("DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9", verificationDelegate: self)
    }
    
    func displayLicenseMessage(message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if !isSuccess {
            if let error = error {
                print("\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.displayLicenseMessage(message: "License initialization failed：" + error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UI Config.
extension CameraViewController {
    private func configureCVR() -> Void {
        cvr = CaptureVisionRouter()
        cvr.addResultReceiver(self)
        
        let mrzTemplatePath = "MRZScanner.json"
        try? cvr.initSettingsFromFile(mrzTemplatePath)
        
        // CVR link DCE.
        try? cvr.setInput(dce)
        
        // Add filter.
        resultFilter = MultiFrameResultCrossFilter()
        resultFilter.enableResultCrossVerification(.textLine, isEnabled: true)
        cvr.addResultFilter(resultFilter)
    }
    
    private func configureDCE() -> Void {
        dceView = CameraView(frame: CGRect(x: 0, y: kNavigationBarFullHeight, width: kScreenWidth, height: kScreenHeight - kNavigationBarFullHeight))
        dceView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(dceView)
        
        dlrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DLR.rawValue)
        dlrDrawingLayer.visible = true
        dce = CameraEnhancer(view: dceView)
        dce.enableEnhancedFeatures(.frameFilter)
    }
    
    private func setupUI() -> Void {
        self.view.addSubview(resultView)
        self.view.addSubview(beepButton)
        // self.view.addSubview(scanLine)
        self.view.addSubview(label)
    }
    
    private func resetUI() -> Void {
        mrzResultModel = MRZResultModel()
        dlrDrawingLayer.clearDrawingItems()
        resultView.text = ""
        
        beepButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        beepButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 25).isActive = true
        
        // scanLine.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        // scanLine.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        label.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -35).isActive = true
    }
}

// MARK: - CapturedResultReceiver.
extension CameraViewController: CapturedResultReceiver {
  
    func onRecognizedTextLinesReceived(_ result: RecognizedTextLinesResult) {
        guard let items = result.items else {
            return
        }
       
        mrzResultModel.recognizedText = items.first?.text
        DispatchQueue.main.async{
            self.resultView.text = self.mrzResultModel.recognizedText
        }
    }
    
    func onParsedResultsReceived(_ result: ParsedResult) {
        guard let items = result.items else {
            if let recognizedText = mrzResultModel.recognizedText, recognizedText.count > 0 {
                DispatchQueue.main.async {
                    self.resultView.text = String(format: "%@%@", parseFailedTip, recognizedText)
                }
            }
            return
        }
        
        guard let firstItem = items.first, firstItem.parsedFields.keys.isEmpty == false else { return  }
        
        mrzResultModel.parsedResultItem = firstItem
        determineWhetherTheConditionIsMet(mrzResultModel)
    }
    
    func determineWhetherTheConditionIsMet(_ mrzResultModel: MRZResultModel) -> Void {
        guard mrzResultModel.recognizedText != nil &&
            mrzResultModel.parsedResultItem != nil else {
            return
        }
        if isBeep {
            Feedback.beep()
        }
        cvr.stopCapturing()
        dce.clearBuffer()
        
        DispatchQueue.main.async {
            let resultVC = MRZResultViewController()
            resultVC.mrzResultModel = self.mrzResultModel
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
        
    }
}

// MARK: - General methods.
extension CameraViewController {
    private func displayError(_ title: String = "", msg: String, _ acTitle: String = "OK", completion: ConfirmCompletion? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: acTitle, style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


