/*
 * This is the sample of Dynamsoft Document Normalizer.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import UIKit
import DynamsoftCaptureVisionBundle

class EditViewController: UIViewController {
    var data: ImageData!
    var quad: Quadrilateral!
    let editorView = ImageEditorView()
    var layer: DrawingLayer!
    var onDataPassedBack: ((Quadrilateral) -> Void)?
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
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
        view.backgroundColor = .darkText
        self.title = "Editing"
        setupLayout()
        setup()
    }
    
    private func setupLayout() {
        view.insertSubview(editorView, at: 0)
        view.addSubview(button)
        
        editorView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            editorView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            editorView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            editorView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -30),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setup() {
        editorView.imageData = data
        layer = editorView.getDrawingLayer(DrawingLayerId.DDN.rawValue)
        var drawingItems:[QuadDrawingItem] = .init()
        drawingItems.append(.init(quadrilateral: quad))
        layer.drawingItems = drawingItems
    }
    
    @objc func buttonTapped() {
        if let item = editorView.getSelectedDrawingItem(), item.mediaType == .quadrilateral {
            let quadItem:QuadDrawingItem = item as! QuadDrawingItem
            quad = quadItem.quad
        }
        onDataPassedBack?(quad)
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
