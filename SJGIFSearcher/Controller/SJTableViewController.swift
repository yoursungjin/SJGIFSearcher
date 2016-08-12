//
//  SJTableViewController.swift
//  SJGIFSearcher
//
//  Created by SJL on 8/7/16.
//  Copyright © 2016 SJL. All rights reserved.
//

import UIKit

class SJTableViewController: UIViewController {

    enum DisplayMode {
        case Trending, Search
    }
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ratingPicker: UIPickerView!
    @IBOutlet weak var pickerHolder: UIView!
    
    let pickerData = ["g", "y", "pg", "pg-13", "r"] //rating
    var pickerVisible = false
    var targetRating = "g"
    var tempPickedTargetRating = "g"
    
    let networkingClient: SJNetworkingClient = SJNetworkingClient()
    
    var gifViewModelsForTrending: [SJGIFViewModel] = []
    var gifViewModelsForSearch: [SJGIFViewModel] = []
    var query = ""
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchActive = false
    
    var detailViewController: SJDetailViewController? = nil
  
    var displayMode = DisplayMode.Trending
    
    var searchTerm = ""
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the Search Controller
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = true
        tableView.tableHeaderView = searchController.searchBar
        
        //ratingPicker
        ratingPicker.dataSource = self
        ratingPicker.delegate = self
        pickerHolder.alpha = 0.0
        
        getTrending(withRating:targetRating) //default "g"
        
        
        //detailViewController
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? SJDetailViewController
        }
        
        //navigationItem
        updateNavigationItemTitle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rating", style:.Plain , target: self, action: #selector(SJTableViewController.onClickRatingButton(_:)))
        
    }
    
    func updateNavigationItemTitle() {
        var mode = ""
        switch displayMode {
            
        case .Trending:
            mode = "Trending"
            break
        case .Search:
            mode = "Search"
            break
        }
        navigationItem.title = "SJGif " + mode + " : " + targetRating
    }
    
    func getTrending(withRating rating:String) {
        print("trending with rating:" + rating)
        networkingClient.trendingGIFs(limit:10, rating:rating) {
            results in
            self.gifViewModelsForTrending = results
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData();
            })
        }
    }
    
    func getSearch(query query: String, rating:String) {
        print("search_query:" + query + " rating:" + rating)
        networkingClient.searchGIFs(query:query, limit:10, rating:rating) {
            results in
            self.gifViewModelsForSearch = results
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData();
            })
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let gifViewModel: SJGIFViewModel
                let searchTerm: String
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! SJDetailViewController
                
                switch displayMode {
                    
                case .Trending:
                    searchTerm = ""
                    gifViewModel = gifViewModelsForTrending[indexPath.row]
                    break
                case .Search:
                    searchTerm = self.searchTerm
                    gifViewModel = gifViewModelsForSearch[indexPath.row]
                    break
                }
                
                controller.gifViewModel = gifViewModel
                controller.searchTerm = searchTerm
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
}


extension SJTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch displayMode {
        case .Trending:
            return gifViewModelsForTrending.count
        case .Search:
            return gifViewModelsForSearch.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SJGIFTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SJGIFTableViewCell
        
        let gifViewModel: SJGIFViewModel
        
        switch displayMode {
            
        case .Trending:
            gifViewModel = gifViewModelsForTrending[indexPath.row]
            break
        case .Search:
            gifViewModel = gifViewModelsForSearch[indexPath.row]
            break
        }
        
        //gifImageView
        if  gifViewModel.imageData != nil {
            //print("imageData available")
            cell.gifImageView.animateWithImageData(gifViewModel.imageData!)
        } else {
            let url = gifViewModel.url
            
            let request = NSURLRequest(URL:url)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let data = data {
                        cell.gifImageView.animateWithImageData(data)
                        gifViewModel.imageData = data
                        
                    }
                }
            })
            task.resume()
        }
        
        //tags
        cell.tagsLabel.text = gifViewModel.tag
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}



extension SJTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchBar = searchController.searchBar
        let terms:[String]
        if let rawText = searchBar.text {
            terms = rawText.characters.split{$0 == " "}.map(String.init)
            searchTerm = rawText
        } else {
            terms = []
        }
        
        query = ""
        let numOfElements = terms.count
        for i in 0  ..< numOfElements - 1 {
            query += terms[i] + "+"
        }
        query += terms[numOfElements - 1]
        
        
        getSearch(query:query , rating: targetRating)
        searchController.dismissViewControllerAnimated(true) { 
            
        }
        displayMode = .Search
        updateNavigationItemTitle()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        displayMode = .Trending
        updateNavigationItemTitle()
        self.tableView.reloadData()
    }
}


extension SJTableViewController: UIPickerViewDataSource,UIPickerViewDelegate {
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tempPickedTargetRating = pickerData[row]
    }
    
    func onClickRatingButton(sender:UIBarButtonItem) {
        if (pickerVisible) {
            UIView.animateWithDuration(0.25, animations: {
                self.pickerHolder.alpha = 0.0
            })
            sender.title = "Rating"
            
            if (targetRating  == tempPickedTargetRating) {
                print("don't need to update gifs")
            } else {
                 targetRating = tempPickedTargetRating
                switch displayMode {
                case .Trending:
                    getTrending(withRating:targetRating)
                    break
                case .Search:
                    getSearch(query:query , rating:targetRating)
                    break
                }
            }
        } else {
            UIView.animateWithDuration(0.25, animations: {
                self.pickerHolder.alpha = 1.0
            })
            sender.title = "Done"
        }
        pickerVisible = !pickerVisible
        updateNavigationItemTitle()
    }

}
