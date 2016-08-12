//
//  SJNetworkingClient.swift
//  SJGIFSearcher
//
//  Created by iOS on 8/8/16.
//  Copyright © 2016 SJL. All rights reserved.
//

import Foundation
import Alamofire

class SJNetworkingClient: NSObject {
    
    // MARK: - Properties
    let GiphyAPIKey = "dc6zaTOxFJmzC"
    
    // MARK: - Trending
    func trendingGIFs(limit limit: UInt, rating: String, completion: (results: Array<SJGIFViewModel>) -> Void) {
        
        self.giphyTrendingRequest(limit, rating: rating).responseJSON {
            response in
            
            let jsonObject:Dictionary<String,AnyObject>?
            
            do {
                jsonObject = try NSJSONSerialization.JSONObjectWithData(response.data! , options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
            } catch let error as NSError {
                print("json error: \(error)")
                jsonObject = nil
            }
            
            if ((jsonObject) != nil) {
                let gifViewModels = self.gifViewModelArrayFromDictArray(jsonObject!["data"] as! Array<AnyObject>)
                completion(results: gifViewModels)
            }
            
        }
    }
    
    
    func giphyTrendingRequest(limit: UInt, rating: String) -> Request {
        return self.requestForEndPoint("/trending", params:["limit":String(limit),"rating":rating])
    }
    
    
    // MARK: - Search
    func searchGIFs(query query: String, limit: UInt, rating: String, completion: (results: Array<SJGIFViewModel>) -> Void) {
        
        self.giphySearchRequest(query:query, limit:limit, rating:rating).responseJSON {
            response in
            
            let jsonObject:Dictionary<String,AnyObject>?
            
            do {
                jsonObject = try NSJSONSerialization.JSONObjectWithData(response.data! , options:NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
            } catch let error as NSError {
                print("json error: \(error)")
                jsonObject = nil
            }
            
            if ((jsonObject) != nil) {
                let gifViewModels = self.gifViewModelArrayFromDictArray(jsonObject!["data"] as! Array<AnyObject>)
                completion(results: gifViewModels)
            }
            
        }
    }
    
    
    func giphySearchRequest(query query: String, limit: UInt, rating: String) -> Request {
        return self.requestForEndPoint("/search", params:["q":query, "limit":String(limit),"rating":rating])
    }
    
    
    
    
    // MARK: - common request for end point
    func requestForEndPoint(endpoint: String, params: Dictionary<String,AnyObject>) -> Request {
        let base = "http://api.giphy.com/v1/gifs"
        let withEndPoint = String(format:"%@%@",base ,endpoint)
        var paramsWithAPIKey: Dictionary<String,AnyObject> = params
        paramsWithAPIKey["api_key"] = GiphyAPIKey
        return Alamofire.request(.GET, withEndPoint, parameters: paramsWithAPIKey, encoding: .URL, headers: nil)
    }
  
    
    
    func gifViewModelArrayFromDictArray(array:Array<AnyObject>) -> Array<SJGIFViewModel> {
        var gifViewModels = [SJGIFViewModel]()
        for (_, item) in array.enumerate() {
            let gifModel: SJGIFModel = SJGIFModel(fromDictionary:item as! Dictionary<String, AnyObject>)
            let gifViewModel = SJGIFViewModel(fromGifModel: gifModel)
            gifViewModels.append(gifViewModel)
        }
        return gifViewModels
    }
    
    
}
