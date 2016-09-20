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
    @IBOutlet weak var scrollView: UIScrollView!

    var customInputAccessoryView: CustomInputAccessoryView!
    
    weak var gifViewModel: SJGIFViewModel?
    
    var activityVC:UIActivityViewController?
    
    var searchTerm: String? {
        didSet{
            title = searchTerm!
        }
    }
    
    
    override var inputAccessoryView: UIView {
        return customInputAccessoryView
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SJDetailViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SJDetailViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        scrollView.keyboardDismissMode = .Interactive
        scrollView.delegate = self
        
        customInputAccessoryView = CustomInputAccessoryView()
        customInputAccessoryView.delegate = self
        customInputAccessoryView.frame = CGRectMake(0, 0, view.frame.size.width, 44)
        
        
        if let gifViewModel = gifViewModel {
            if let gifImageView = gifImageView , detailDescriptionLabel = detailDescriptionLabel {
                if let imageData = gifViewModel.imageData {
                    gifImageView.animateWithImageData(imageData)
                    detailDescriptionLabel.text = gifViewModel.tag
                } else {
                    detailDescriptionLabel.text = "Sorry, the image data is not available. Try again later."
                }
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gifViewModel = gifViewModel {
            //gifImageView
            if let height = gifViewModel.height, width = gifViewModel.width {
                let ratio:CGFloat = height/width
                let screenWidth = UIScreen.mainScreen().bounds.width;
                gifImageView.frame = CGRectMake(0, 0, screenWidth, screenWidth * ratio)
            }
        }
        
        //tag
        let labelY = gifImageView.frame.origin.y + gifImageView.frame.size.height
        detailDescriptionLabel.frame.origin = CGPoint(x :0, y:labelY)
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        //print("sjdetaikViewController.deinit")
    }

    
    func keyboardWillBeHidden(aNotification:NSNotification) {
        let contentInsets = UIEdgeInsetsZero;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    
    func keyboardWillShow(aNotification:NSNotification) {
        
        let info:NSDictionary = aNotification.userInfo!
        let kbSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue().size
        //print("kbSize!.height:" + kbSize!.height.description)
        let contentInsets = UIEdgeInsetsMake(0, 0.0, kbSize!.height, 0.0) // top left bottom right
 
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        //make the last element visible
        self.scrollView.scrollRectToVisible(detailDescriptionLabel.frame, animated: false)
    }
    

    
    @IBAction func onClickShare(sender: UIButton) {
        
        
        var textToShare = ""
        if let tags = detailDescriptionLabel.text, customString = customInputAccessoryView.commentField.text {
            textToShare = tags + "\n" + customString
        } else if let tags = detailDescriptionLabel.text {
            textToShare = tags + "\n"
        } else if let customString = customInputAccessoryView.commentField.text{
            textToShare = customString
        }
        
        //print("textToShare" + textToShare)
        
        
        if let imageData = gifViewModel?.imageData {
            let objectsToShare = [textToShare, imageData]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityTypePrint,UIActivityTypeAirDrop,UIActivityTypeAddToReadingList,UIActivityTypeAssignToContact,UIActivityTypeCopyToPasteboard]
            activityVC.popoverPresentationController?.sourceView = self.view
            self.presentViewController(activityVC, animated: true, completion: nil)
            
        }
    }
    
    
}



extension SJDetailViewController: CustomInputAccessoryViewDelegate {
    
    func onClickSend(customInputAcessoryView customInputAcessoryView: CustomInputAccessoryView, sender: UIButton) {
        customInputAccessoryView.commentField.resignFirstResponder()
        onClickShare(sender)
        customInputAccessoryView.commentField.text = "" //clear the field
    }
    
}


extension SJDetailViewController: UIScrollViewDelegate {
    //ios9 issue http://stackoverflow.com/a/34101920
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        customInputAccessoryView.commentField.resignFirstResponder()
    }
}
