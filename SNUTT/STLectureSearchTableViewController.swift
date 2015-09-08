//
//  STLectureSearchTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit

class STLectureSearchTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, LoadMoreTableFooterDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var FilteredList : [STLecture] = []
    var SearchingString : String = ""
    var pageNum : Int = 0
    var loadMoreView = LoadMoreTableFooterView()
    var shouldShowResult = true
    func reloadData() {
        tableView.reloadData()
        if pageNum == -1 {
            loadMoreView.hidden = true
        } else {
            loadMoreView.hidden = false
        }
        loadMoreView.frame = CGRect(x: 0.0, y: tableView.contentSize.height, width: tableView.frame.size.width, height: tableView.bounds.size.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLectureList("")
        reloadData()
        loadMoreView.delegate = self
        tableView.addSubview(loadMoreView)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    var isGettingLecture = false
    func getLectureList(searchString : String) {
        if isGettingLecture {
            return
        }
        isGettingLecture = true
        FilteredList = []
        var queryText = searchString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var url : String  = "http://snutt.kr/api/search_query?year=2015&semester=2&filter=&type=course_title&query_text=\(queryText)&page=1&per_page=30"
        var jsonData = NSData(contentsOfURL: NSURL(string: url)!)
        var jsonDictionary = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: nil) as! NSDictionary
        var searchResult = jsonDictionary["lectures"] as! [NSDictionary]
        for it in searchResult {
            FilteredList.append(STLecture(json: it))
        }
        SearchingString = searchString
        pageNum = 1
        if searchResult.count != 30 {
            pageNum = -1
        }
        isGettingLecture = false
        tableView.setContentOffset(CGPoint(x:0.0,y:0.0), animated: false)
    }
    func getMoreLectureList() {
        if isGettingLecture {
            return
        }
        isGettingLecture = true
        if pageNum == -1 {
            return
        }
        pageNum++
        var queryText = SearchingString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var currentCourseBook = STCourseBooksManager.sharedInstance.currentCourseBook!
        var url : String  = "http://snutt.kr/api/search_query?year=\(currentCourseBook.year)&semester=\(currentCourseBook.semester)&filter=&type=course_title&query_text=\(queryText)&page=\(pageNum)&per_page=30"
        var jsonData = NSData(contentsOfURL: NSURL(string: url)!)
        var jsonDictionary = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: nil) as! NSDictionary
        var searchResult = jsonDictionary["lectures"] as! [NSDictionary]
        for it in searchResult {
            FilteredList.append(STLecture(json: it))
        }
        if searchResult.count != 30 {
            pageNum = -1
        }
        isGettingLecture = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if shouldShowResult {
            return 1
        }
        return 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return FilteredList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tmpCell = tableView.dequeueReusableCellWithIdentifier("LectureSearchCell", forIndexPath: indexPath) as? UITableViewCell
        if (tmpCell == nil) {
            tmpCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "LectureSearchCell")
        }
        let cell = tmpCell as! STLectureSearchTableViewCell
        cell.lecture = FilteredList[indexPath.row]
        cell.button.hidden = true
        return cell
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tableView.hidden = true
        searchBar.showsCancelButton = true
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        tableView.hidden = false
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        getLectureList(searchBar.text)
        tableView.hidden = false
        reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        if searchBar.text == "" {
            getLectureList("")
            reloadData()
        } else {
            searchBar.text = SearchingString
        }
        tableView.hidden = false
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
    
    @IBAction func buttonAction(sender: AnyObject) {
        let cell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow()!) as! STLectureSearchTableViewCell
        /*
        var frame = cell.frame
        var center = cell.center
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options : nil,
            animations: {
                cell.center = CGPoint(x: 0, y: self.tableView.frame.size.height)
                cell.transform = CGAffineTransformMakeScale(0.1, 0.1)
            },
            completion: { finished in
                cell.center = center
                UIView.animateWithDuration(0.5) {
                    cell.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }
        })
        */
        cell.button.hidden = true
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: true)
        

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! STLectureSearchTableViewCell
        cell.button.hidden = false
        //TimeTableCollectionViewController.datasource.addLecture(FilteredList[indexPath.row])
        
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! STLectureSearchTableViewCell
        cell.button.hidden = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if pageNum != -1 {
            loadMoreView.loadMoreScrollViewDidScroll(scrollView)
        }
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if pageNum != -1 {
            loadMoreView.loadMoreScrollViewDidEndDragging(scrollView)
        }
    }
    
    // MARK: LoadMoreTableFooterDelegate
    var isLoading = false
    func loadMoreTableFooterDidTriggerLoadMore(view: LoadMoreTableFooterView!) {
        isLoading = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0)) {
            self.getMoreLectureList()
            dispatch_sync(dispatch_get_main_queue()) {
                self.isLoading = false
                self.reloadData()
                self.loadMoreView.loadMoreScrollViewDataSourceDidFinishedLoading(self.tableView)
            }
        }
    }
    
    func loadMoreTableFooterDataSourceIsLoading(view: LoadMoreTableFooterView!) -> Bool {
        return isLoading
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        NSLog("Log")
    }
    */

}