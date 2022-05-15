//
//  CapturedImageVC.swift
//  PortraitCameraEffect
//
//  Created by Bradley Hoang on 15/05/2022.
//

import UIKit

class CapturedImageVC: UIViewController {
    
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var showButton: UIButton!
    
    private enum State {
        case original
        case blurring
    }
    private var state: State = .blurring
    
    var originalImage: UIImage?
    var blurringImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        showImage(withState: .blurring)
    }
    
    private func showImage(withState state: State) {
        switch state {
        case .original:
            capturedImageView.image = originalImage
            showButton.setTitle("Show blurring image", for: .normal)
            
        case .blurring:
            capturedImageView.image = blurringImage
            showButton.setTitle("Show original image", for: .normal)
        }
    }
    
    @IBAction func showButtonTapped(_ sender: Any) {
        state = state == .blurring ? .original : .blurring
        showImage(withState: state)
    }
}
