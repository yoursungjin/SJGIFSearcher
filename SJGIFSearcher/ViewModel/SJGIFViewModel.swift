//
//  SJGIFViewModel.swift
//  SJGIFSearcher
//
//  Created by SJL on 8/7/16.
//  Copyright © 2016 SJL. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SJGIFViewModel: NSObject {
    
    
    let gifModel: SJGIFModel
    
    var url: NSURL?
    var width: CGFloat?
    var height: CGFloat?
    
    var tag = ""
    
    var imageData: NSData?
    
    
    init(fromGifModel giphyModel: SJGIFModel) {
        
        gifModel = giphyModel
        
        
        if let images = gifModel.images {
            if let imageDetails:Dictionary<String,String> = (images["fixed_width"] as! Dictionary)  {
                if let urlString = imageDetails["url"] {
                    url = NSURL(string: urlString)!
                }
                width = CGFloat(Double(imageDetails["width"]!)!)
                height = CGFloat(Double(imageDetails["height"]!)!)
            }
        }
        
        
        if let slug = gifModel.slug {
            let tags = slug.characters.split{$0 == "-"}.map(String.init)
            for i in 0  ..< tags.count - 1   {
                tag += " #" + tags[i]
            }
        }
        
        super.init()
        

        //imageData - 2nd phase initialization
        if let url = self.url {
                let urlString = url.absoluteString
                Alamofire.request(.GET, urlString, parameters: nil, encoding: .URL, headers: nil)
                    .response { request, response, data, error in
                        self.imageData = data
                        SJNetworkingClient.sharedInstance.numberOfFullyLoadedModels += 1
            }
        }

    }
    
    
}