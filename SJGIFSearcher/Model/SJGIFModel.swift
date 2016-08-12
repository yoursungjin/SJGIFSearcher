//
//  SJGIFModel.swift
//  SJGIFSearcher
//
//  Created by SJL on 8/7/16.
//  Copyright © 2016 SJL. All rights reserved.
//

import Foundation

class SJGIFModel: NSObject {
    
    let gifID: String
    let type: String
    let username: String?
    let rating: String
    let slug: String
    
    let url: NSURL
    let bitlyURL: NSURL
    let bitlyGIFURL: NSURL
    let embedURL: NSURL
    let source: NSURL?
   
    let trendingDateTime: NSDate?
    
    let images: Dictionary<String,AnyObject>
    
    init(fromDictionary dictionary: Dictionary<String,AnyObject>) {
 
        self.gifID = dictionary["id"] as! String
        self.type = dictionary["type"] as! String
        self.username = dictionary["username"] as! String
        self.rating = dictionary["rating"] as! String
        self.slug = dictionary["slug"] as! String
        
        self.url = NSURL(string: dictionary["url"] as! String)!
        self.bitlyURL = NSURL(string: dictionary["bitly_url"] as! String)!
        self.bitlyGIFURL = NSURL(string: dictionary["bitly_gif_url"] as! String)!
        self.embedURL = NSURL(string: dictionary["embed_url"] as! String)!
        self.source = NSURL(string: dictionary["source"] as! String)
       
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.trendingDateTime = dateFormatter.dateFromString(dictionary["trending_datetime"] as! String)
        
        images = dictionary["images"] as! Dictionary
        
        super.init()
    }


}