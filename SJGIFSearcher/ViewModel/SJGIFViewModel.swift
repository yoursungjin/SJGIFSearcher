//
//  SJGIFViewModel.swift
//  SJGIFSearcher
//
//  Created by SJL on 8/7/16.
//  Copyright © 2016 SJL. All rights reserved.
//

import Foundation
import UIKit
import Gifu

class SJGIFViewModel: NSObject {
    
    
    let gifModel: SJGIFModel
    let url: NSURL

    var width: CGFloat
    var height: CGFloat
    
    var tag = ""

    var imageData: NSData?
    
    init(fromGifModel giphyModel: SJGIFModel) {
       
        gifModel = giphyModel
        let imageDetails: Dictionary<String,String> = gifModel.images["fixed_width"] as! Dictionary
        url = NSURL(string: imageDetails["url"]!)!

        width = CGFloat(Double(imageDetails["width"]!)!)
        height = CGFloat(Double(imageDetails["height"]!)!)
        
        let tags = gifModel.slug.characters.split{$0 == "-"}.map(String.init)
        for i in 0  ..< tags.count - 1   {
            tag += " #" + tags[i]
        }
        
        super.init()
    }
    
    
    
}