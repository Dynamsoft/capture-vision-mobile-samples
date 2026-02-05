/*
 * This is the sample of Dynamsoft Document Normalizer.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class ResultViewController: UIViewController {
    var data: ImageData!
    var quad: Quadrilateral!
    let cvr = CaptureVisionRouter()
    var mode = ImageColourMode.colour
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let bottomToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = .darkText
        return view
    }()
    
    private lazy var leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.init(named: "left")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var middleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.init(named: "middle")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(middleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.init(named: "right")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let colourModeOptions: [ImageColourMode] = [.colour, .grayscale, .binary]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Result"
        view.backgroundColor = .darkGray
        setupLayout()
        updateImageView(withColourMode: mode)
    }
    
    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(bottomToolbar)
        bottomToolbar.addSubview(leftButton)
        bottomToolbar.addSubview(middleButton)
        bottomToolbar.addSubview(rightButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        middleButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomToolbar.topAnchor, constant: -10),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor),
            
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 120),
            
            leftButton.leadingAnchor.constraint(equalTo: bottomToolbar.leadingAnchor),
            leftButton.topAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            leftButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            leftButton.widthAnchor.constraint(equalTo: bottomToolbar.widthAnchor, multiplier: 1/3),
            
            middleButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor),
            middleButton.topAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            middleButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            middleButton.widthAnchor.constraint(equalTo: bottomToolbar.widthAnchor, multiplier: 1/3),
            
            rightButton.leadingAnchor.constraint(equalTo: middleButton.trailingAnchor),
            rightButton.topAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            rightButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            rightButton.widthAnchor.constraint(equalTo: bottomToolbar.widthAnchor, multiplier: 1/3)
        ])
    }
    
    private func updateImageView(withColourMode mode: ImageColourMode) {
        let name = PresetTemplate.normalizeDocument.rawValue
        // Get the current simplified settings.
        if let settings = try? cvr.getSimplifiedSettings(name) {
            settings.documentSettings?.colourMode = mode
            // Set the previously detected boundary as the new ROI.
            settings.roi = quad
            settings.roiMeasuredInPercentage = false
            // Update the settings.
            try? cvr.updateSettings(name, settings: settings)
        }
        // Capture the image again with the new ROI.
        let result = cvr.captureFromBuffer(data, templateName: name)
        guard let items = result.items else { return }
        for item in items {
            if item.type == .enhancedImage {
                let imageItem:EnhancedImageResultItem = item as! EnhancedImageResultItem
                // Get the normalized image and display it on the view.
                let image = try? imageItem.imageData?.toUIImage()
                DispatchQueue.main.async { [self] in
                    imageView.image = image
                }
                return
            }
        }
    }
    
    // MARK: - Actions
    @objc private func leftButtonTapped() {
        let vc = EditViewController()
        vc.data = data
        vc.quad = quad
        vc.onDataPassedBack = { [weak self] quad in
            self?.quad = quad
            self?.updateImageView(withColourMode: self?.mode ?? .colour)
        }
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func middleButtonTapped() {
        let alertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        for mode in colourModeOptions {
            var title: String
            switch mode {
            case .colour:
                title = "Colour"
            case .grayscale:
                title = "GrayScale"
            case .binary:
                title = "Binary"
            @unknown default:
                title = "Colour"
            }
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.mode = mode
                self?.updateImageView(withColourMode: mode)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func rightButtonTapped() {
        guard let imageToSave = imageView.image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if error != nil {
            showResult("Error saving image: ", "Please make sure you have granted the 'Photo Library Additions' permission")
        } else {
            showResult("Successfully saved to your album!", nil)
        }
    }
    
    private func showResult(_ title: String, _ message: String?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
