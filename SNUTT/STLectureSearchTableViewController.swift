//
//  STLectureSearchTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire

class STLectureSearchTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar : STSearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tagTableView: STTagListView!
    var timetableViewController : STTimetableCollectionViewController!
    
    var FilteredList : [STLecture] = []
    var pageNum : Int = 0
    
    enum SearchState {
        case Empty
        case Loading(Request)
        case Loaded(String)
    }
    var state : SearchState = SearchState.Empty
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        STEventCenter.sharedInstance.addObserver(self, selector: "timetableSwitched", event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: "reloadTimetable", event: STEvent.CurrentTimetableChanged, object: nil)
        
        searchBar.tagTableView = tagTableView
        tagTableView.searchBar = searchBar
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getLectureList(searchString : String) {
        let request = Alamofire.request(STSearchRouter.Search(query: searchString))
        state = .Loading(request)
        request.responseSwiftyJSON { response in
            self.state = .Loaded(searchString)
            switch response.result {
            case .Success(let json):
                self.FilteredList = json.arrayValue.map { data in
                    return STLecture(json: data)
                }
                self.reloadData()
            case .Failure(let error):
                //TODO : Alertview for failure
                print(error)
            }
        }
    }
    func getMoreLectureList() {
        /* //FIXME : DEBUG
        if isGettingLecture {
            return
        }
        isGettingLecture = true
        if pageNum == -1 {
            return
        }
        pageNum++
        let queryText = SearchingString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let currentCourseBook = STCourseBooksManager.sharedInstance.currentCourseBook!
        let url : String  = "http://snutt.kr/api/search_query?year=\(currentCourseBook.year)&semester=\(currentCourseBook.semester)&filter=&type=course_title&query_text=\(queryText)&page=\(pageNum)&per_page=30"
        let jsonData = NSData(contentsOfURL: NSURL(string: url)!)
        let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(jsonData!, options: [])) as! NSDictionary
        let searchResult = jsonDictionary["lectures"] as! [NSDictionary]
        for it in searchResult {
            FilteredList.append(STLecture(json: it))
        }
        if searchResult.count != 30 {
            pageNum = -1
        }
        isGettingLecture = false
        */
    }
    
    func timetableSwitched() {
        state = .Empty
        //searchBar.text = ""
        FilteredList = []
    }
    
    func reloadTimetable() {
        self.timetableViewController.reloadTimetable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        switch state {
        case .Loaded:
            return 1
        case .Loading, .Empty:
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return FilteredList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tmpCell = tableView.dequeueReusableCellWithIdentifier("LectureSearchCell", forIndexPath: indexPath) as UITableViewCell
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
        switch state {
        case .Loading(let request):
            request.cancel()
        default:
            break
        }
        getLectureList(searchBar.text!)
        tableView.hidden = false
        reloadData()
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        switch state {
        case .Empty, .Loading:
            break
        case .Loaded(let queryString):
            searchBar.text = queryString
        }
        tableView.hidden = false
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    
    @IBAction func buttonAction(sender: AnyObject) {
        let cell = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!) as! STLectureSearchTableViewCell
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
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: true)
        

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! STLectureSearchTableViewCell
        cell.button.hidden = false
        STTimetableManager.sharedInstance.setTemporaryLecture(FilteredList[indexPath.row], object: self)
        //TimetableCollectionViewController.datasource.addLecture(FilteredList[indexPath.row])
        
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! STLectureSearchTableViewCell
        cell.button.hidden = true
        if STTimetableManager.sharedInstance.currentTimetable?.temporaryLecture === FilteredList[indexPath.row] {
            STTimetableManager.sharedInstance.setTemporaryLecture(nil, object: self)
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "STSearchTimetableView") {
            timetableViewController = (segue.destinationViewController as! STTimetableCollectionViewController)
            timetableViewController.timetable = STTimetableManager.sharedInstance.currentTimetable
            timetableViewController.showTemporary = true
        }
    }
    

}
