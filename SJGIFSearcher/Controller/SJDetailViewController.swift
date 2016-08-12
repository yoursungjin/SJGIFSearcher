//
//  SJDetailViewController.swift
//  SJGIFSearcher
//
//  Created by SJL on 8/10/16.
//  Copyright © 2016 SJL. All rights reserved.
//

import Foundation
import UIKit
import Gifu

class SJDetailViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: AnimatableImageView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    weak var gifViewModel: SJGIFViewModel?
    
    var searchTerm: String? {
        didSet{
            title = searchTerm!
        }
    }
    
    func configureView() {
        
        if let gifViewModel = gifViewModel {
            if let gifImageView = gifImageView , detailDescriptionLabel = detailDescriptionLabel {
                gifImageView.animateWithImageData(gifViewModel.imageData!)
                detailDescriptionLabel.text = gifViewModel.tag
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //gifImageView
        let ratio:CGFloat = gifViewModel!.height/gifViewModel!.width
        let screenWidth = UIScreen.mainScreen().bounds.width;
        gifImageView.frame.size = CGSize(width: screenWidth, height: screenWidth * ratio)
     
        //tag
        let labelY = gifImageView.frame.origin.y + gifImageView.frame.size.height
        detailDescriptionLabel.frame.origin = CGPoint(x :0, y:labelY)
    }
    

}
