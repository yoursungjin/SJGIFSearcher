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
    
    let pickerData = ["G", "Y", "PG", "PG-13", "R"] //rating
    var pickerVisible = false
    var currentRating = ""
    var newRating = "G"
   
    let networkingClient = SJNetworkingClient.sharedInstance
    
    var gifViewModelsForTrending: [SJGIFViewModel] = []
    var gifViewModelsForSearch: [SJGIFViewModel] = []
    
    var currentQuery = ""
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchActive = false
    
    var detailViewController: SJDetailViewController? = nil
  
    var displayMode = DisplayMode.Trending
    
    var searchTerm = ""
    
    let indicatorView = UIActivityIndicatorView()
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //networkingClient KVO
        networkingClient.addObserver(self, forKeyPath:"isAllLoaded", options:.New, context:nil)
        networkingClient.addObserver(self, forKeyPath:"isGifViewModelsSet", options:.New, context:nil)

        tableViewSetting()
        
        // Setup the Search Controller
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = true
        tableView.tableHeaderView = searchController.searchBar

        //ratingPicker
        ratingPicker.dataSource = self
        ratingPicker.delegate = self
        pickerHolder.alpha = 0.0

        
        //get Data
        getTrending(withRating:"G") //default "g"
        
        
        //detailViewController
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? SJDetailViewController
        }
        
        //navigationItem
        updateNavigationItemTitle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rating", style:.Plain , target: self, action: #selector(SJTableViewController.onClickRatingButton(_:)))
        navigationItem.leftBarButtonItem = nil
        
        
    }
    
    
    func tableViewSetting() {
        tableView.dataSource = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        let containerView = UIView()

        let logoImagView = UIImageView(image: UIImage(named:"gifHubLogo"))
        let logoImagViewSizeWidth = view.frame.size.width * 0.7
        logoImagView.frame = CGRectMake((view.frame.width - logoImagViewSizeWidth)/2,(view.frame.height - logoImagViewSizeWidth)/2,logoImagViewSizeWidth,logoImagViewSizeWidth)
        containerView.addSubview(logoImagView)
        
        indicatorView.hidesWhenStopped = true
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicatorView.center = view.center;
        containerView.addSubview(indicatorView)

        tableView.backgroundView = containerView
        indicatorView.startAnimating()
        
    }


    func updateNavigationItemTitle() {
        
        var plainString = ""
        
        switch displayMode {
    
        case .Trending:
            plainString = "Trending" + " in " + currentRating
            break
        case .Search:
            plainString = "Search" + " in " + currentRating
            break
        }
        
        let attributedString = NSMutableAttributedString(string:plainString)
        let rangeOfTargetString = (plainString as NSString).rangeOfString(" in ")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.SJThemeColor() , range: rangeOfTargetString)

        
        let titleLabel = UILabel()
        titleLabel.attributedText = attributedString
        titleLabel.sizeToFit()
        
        navigationItem.titleView = titleLabel
    }
    
    
    // MARK: - Giphy Endpoints
    func getTrending(withRating rating:String) {
        
        indicateLoading()
        
        //fetch data
        currentRating = rating
        print("trending with rating.lowercaseString:" + currentRating.lowercaseString)
        networkingClient.resetToReload()
        networkingClient.trendingGIFs(limit:10, rating:currentRating.lowercaseString) {
            results in
            self.gifViewModelsForTrending = results
        }
    }
    
    
    func getSearch(query query: String, rating:String) {
        
        indicateLoading()
        
        currentQuery = query
        currentRating = rating
        print("search_query:" + currentQuery + " rating.lowercaseString:" + currentRating.lowercaseString)
        networkingClient.resetToReload()
        networkingClient.searchGIFs(query:currentQuery, limit:10, rating:currentRating.lowercaseString) {
            results in
            self.gifViewModelsForSearch = results
            if self.gifViewModelsForSearch.count == 0 {
                self.networkingClient.isAllLoaded = true
                print("No search results")
                let alert = UIAlertController(title: "Alert", message: "No search results", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }

    }
    

    func indicateLoading() {
        switch displayMode {
            
        case .Trending:
            gifViewModelsForTrending = []
            break
        case .Search:
            
            gifViewModelsForSearch = []
            break
        }
        
        tableView.reloadData()
        indicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
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
                    searchTerm = "Share"
                    gifViewModel = gifViewModelsForTrending[indexPath.row]
                    break
                case .Search:
                    searchTerm = "Share" + " " + self.searchTerm
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
    
    
    // MARK: - KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if networkingClient.isAllLoaded && networkingClient.isGifViewModelsSet {
            tableView.dataSource = self

            tableView.reloadData()

            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.indicatorView.stopAnimating()
            }
        }
    }
    
    
    deinit {
        networkingClient.removeObserver(self, forKeyPath: "isAllLoaded")
        networkingClient.removeObserver(self, forKeyPath: "isGifViewModelsSet")
    }
}


extension SJTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - Table View
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return 1
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
        dispatch_async(dispatch_get_main_queue()) {
            if let imageData = gifViewModel.imageData {
                cell.gifImageView.animateWithImageData(imageData)
            }
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
        
        var newQuery = ""
        let numOfElements = terms.count
        for i in 0  ..< numOfElements - 1 {
            newQuery += terms[i] + "+"
        }
        newQuery += terms[numOfElements - 1]
        
        displayMode = .Search
        updateNavigationItemTitle()
        
        getSearch(query:newQuery , rating: currentRating)
        searchController.dismissViewControllerAnimated(true,completion: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style:.Plain , target: self, action: #selector(SJTableViewController.onClickCancelButton(_:)))
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        if searchController.searchBar.text == "" {
            returnToTrendingMode()
        }
    }
    
    
    func onClickCancelButton(sender:UIBarButtonItem) {
        returnToTrendingMode()
    }
    
    
    func returnToTrendingMode() {
        displayMode = .Trending
        getTrending(withRating: currentRating)
      
        updateNavigationItemTitle()
        
        navigationItem.leftBarButtonItem = nil
        searchController.searchBar.text = ""
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
        newRating = pickerData[row]
    }
    
    func onClickRatingButton(sender:UIBarButtonItem) {
        if pickerVisible {
            UIView.animateWithDuration(0.25, animations: {
                self.pickerHolder.alpha = 0.0
            })
            sender.title = "Rating"
            
            switch displayMode {
            case .Trending:
                getTrending(withRating:newRating)
                break
            case .Search:
                getSearch(query:currentQuery , rating:newRating)
                break
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

