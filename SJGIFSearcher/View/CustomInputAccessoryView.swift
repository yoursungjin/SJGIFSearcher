//
//  CustomInputAccessoryView.swift
//  SJGIFSearcher
//
//  Created by SJL on 9/5/16.
//  Copyright © 2016 SJL. All rights reserved.
//


import UIKit

//@IBDesignable it doesn't work. don't know why

protocol CustomInputAccessoryViewDelegate: class  {
    func onClickSend(customInputAcessoryView customInputAcessoryView:CustomInputAccessoryView, sender : UIButton)
}


class CustomInputAccessoryView : UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    weak var delegate:CustomInputAccessoryViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    func commonSetup() {
        NSBundle.mainBundle().loadNibNamed("CustomInputAccessoryView", owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView);
    }
    
    
    @IBAction func onClickSend(sender: UIButton) {
        delegate?.onClickSend(customInputAcessoryView: self, sender: sender)
    }

}

