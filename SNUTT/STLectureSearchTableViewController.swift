//
//  STLectureSearchTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire
import DZNEmptyDataSet
import RxSwift

class STLectureSearchTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var searchBar : STSearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tagCollectionView: STTagCollectionView!
    @IBOutlet weak var tagTableView: STTagListView!
    @IBOutlet weak var tagCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet var searchToolbarView: STLectureSearchToolbarView!
    @IBOutlet weak var timetableView: STTimetableView!

    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!
    let settingManager = AppContainer.resolver.resolve(STSettingManager.self)!
    let colorManager = AppContainer.resolver.resolve(STColorManager.self)!
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let disposeBag = DisposeBag()
    var FilteredList : [STLecture] = [] {
        didSet(oldVal) {
            print(oldVal)
        }
    }
    var pageNum : Int = 0
    var perPage : Int = 20
    var isLast : Bool = false
    
    enum SearchState {
        case empty
        case editingQuery(String?, [STTag], [STLecture])
        case loading(Disposable)
        case loaded(String, [STTag])
    }
    var state : SearchState = SearchState.empty
    
    func reloadData() {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.emptyDataSetSource = self;
        tableView.emptyDataSetDelegate = self;
        
        searchBar.searchController = self
        tagTableView.searchController = self
        tagCollectionView.searchController = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)

        initEmptyDataSet()

        tableView.register(UINib(nibName: "STLectureSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "STLectureSearchTableViewCell")
        
        //Tag Button to KeyboardToolbar
        
        searchBar.inputAccessoryView = searchToolbarView
        
        timetableManager.rx.currentTimetable
            .map { $0?.id }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.timetableSwitched()
            }).disposed(by: disposeBag)

        Observable.combineLatest(
            timetableManager.rx.currentTimetable,
            timetableManager.rx.currentTemporaryLecture
        ) { a, b in (a,b)}
            .subscribe(onNext: { [weak self] (timetable, tempLecture) in
                self?.timetableView.setTimetable(timetable, tempLecture: tempLecture)
            }).disposed(by: disposeBag)

        settingManager.rx.fitMode
            .subscribe(onNext: {[weak self] fitMode in
                self?.timetableView.setFitMode(fitMode)
            }).disposed(by: disposeBag)

        colorManager.rx.colorList
            .subscribe(onNext: {[weak self] colorList in
                self?.timetableView.setColorList(colorList)
            }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    func getLectureList(_ searchString : String) {
        // This is for saving the request
        isLast = false
        let tagList = tagCollectionView.tagList
        let mask = searchToolbarView.isEmptyTime ? timetableManager.currentTimetable?.timetableReverseTimeMask() : nil
        guard let quarter = timetableManager.currentTimetable?.quarter else { return }

        let disposable = requestSearch(quarter: quarter, query: searchString, tagList: tagList, mask: mask, offset: 0, limit: perPage)
            .subscribe(onSuccess: { [weak self] lectureList in
                guard let self = self else { return }
                self.FilteredList = lectureList
                self.state = .loaded(searchString, tagList)
                if lectureList.count < self.perPage {
                    self.isLast = true
                }
                self.pageNum = 1
                self.reloadData()
            }, onError: { [weak self] err in
                guard let self = self else { return }
                self.errorHandler.apiOnError(err)
                self.state = .empty
                self.FilteredList = []
                self.reloadData()
            })
        state = .loading(disposable)
        disposeBag.insert(disposable)
    }
    
    func getMoreLectureList(_ searchString: String) {
        let tagList = tagCollectionView.tagList
        let mask = searchToolbarView.isEmptyTime ? timetableManager.currentTimetable?.timetableReverseTimeMask() : nil
        guard let quarter = timetableManager.currentTimetable?.quarter else { return }

        let disposable = requestSearch(quarter: quarter, query: searchString, tagList: tagList, mask: mask, offset: perPage * pageNum, limit: perPage)
            .subscribe(onSuccess: { [weak self] lectureList in
                guard let self = self else { return }
                self.state = .loaded(searchString, tagList)
                self.FilteredList = self.FilteredList + lectureList
                if lectureList.count < self.perPage {
                    self.isLast = true
                }
                self.pageNum = self.pageNum + 1
                self.reloadData()
                }, onError: { [weak self] err in
                    guard let self = self else { return }
                    self.errorHandler.apiOnError(err)
                    self.state = .empty
                    self.FilteredList = []
                    self.reloadData()
            })
        state = .loading(disposable)
        disposeBag.insert(disposable)
    }

    private func requestSearch(quarter: STQuarter, query: String, tagList: [STTag], mask: [Int]?, offset: Int, limit: Int) -> Single<[STLecture]>{
        let year = quarter.year
        let semester = quarter.semester
        var credit : [Int] = []
        var instructor : [String] = []
        var department : [String] = []
        var academicYear : [String] = []
        var classification : [String] = []
        var category : [String] = []
        for tag in tagList {
            switch tag.type {
            case .Credit:
                credit.append(Int(tag.text.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))!)
            case .Department:
                department.append(tag.text)
            case .Instructor:
                instructor.append(tag.text)
            case .AcademicYear:
                academicYear.append(tag.text)
            case .Classification:
                classification.append(tag.text)
            case .Category:
                category.append(tag.text)
            }
        }
        let params = STTarget.SearchLectures.Params(
            title: query,
            year: year,
            semester: semester,
            credit: credit,
            instructor: instructor,
            department: department,
            academic_year: academicYear,
            classification: classification,
            category: category,
            offset: offset,
            limit: limit
        )
        return networkProvider.rx.request(STTarget.SearchLectures(params: params))
    }

    func setFocusToSearch() {
        searchBar.becomeFirstResponder()
    }
    
    let heightForFetch = CGFloat(50.0)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height == 0 {
            return
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - heightForFetch && !isLast{
            if case SearchState.loaded(let searchString, let _) = state {
                getMoreLectureList(searchString)
            }
        }
    }
    
    func timetableSwitched() {
        state = .empty
        searchBar.text = ""
        FilteredList = []
        tagTableView.filteredList = []
        tagCollectionView.tagList = []
        searchToolbarView.currentTagType = nil
        searchToolbarView.isEmptyTime = false
        
        self.reloadData()
        tagTableView.hide()
        tagCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        switch state {
        case .loaded:
            return 1
        case .loading, .empty, .editingQuery:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return FilteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STLectureSearchTableViewCell", for: indexPath) as! STLectureSearchTableViewCell
        cell.lecture = FilteredList[indexPath.row]
        cell.tableView = tableView
        return cell
    }
    
    func searchBarSearchButtonClicked(_ query : String) {
        switch state {
        case .loading(let request):
            request.dispose()
        default:
            break
        }
        getLectureList(query)
        reloadData()
    }
    func searchBarCancelButtonClicked() {
        switch state {
        case .editingQuery(let query, let tagList, let lectureList):
            state = .empty
            FilteredList = []
            searchBar.text = ""
            tagCollectionView.tagList = []
        case .loading(let request):
            request.dispose()
            state = .empty
            FilteredList = []
            searchBar.text = ""
            tagCollectionView.tagList = []
        default: break
        }
        reloadData()
        tagCollectionView.reloadData()
    }

    var willSelectRow: Bool = false
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        willSelectRow = false
        timetableManager.setTemporaryLecture(FilteredList[indexPath.row])
        //TimetableCollectionViewController.datasource.addLecture(FilteredList[indexPath.row])
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if timetableManager.currentTemporaryLecture == FilteredList[indexPath.row] && !willSelectRow {
            timetableManager.setTemporaryLecture(nil)
        }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        willSelectRow = true
        return indexPath
    }
    
    func addTag(_ tag: STTag) {
        searchBar.disableEditingTag()
        tagCollectionView.tagList.append(tag)
        if tagCollectionView.tagList.count == 1 {
            let indexPath = IndexPath(row: 0, section: 0)
            tagCollectionView.reloadData()
            tagCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: false)
        } else {
            let indexPath = IndexPath(row: tagCollectionView.tagList.count - 1, section: 0)
            tagCollectionView.insertItems(at: [indexPath])
            tagCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.right, animated: true)
        }
        tagCollectionView.setHidden()
        tagTableView.hide()
    }
    
    func showTagRecommendation() {
        tagTableView.showTagsFor(searchBar.text!, type: searchToolbarView.currentTagType)
        tagTableView.setContentOffset(CGPoint(x: 0, y: -tagTableView.contentInset.top), animated: true)
    }
    
    func hideTagRecommendation() {
        tagTableView.hide()
    }
    
    //MARK: DNZEmptyDataSet

    var emptyInfoView: STSearchEmptyInfoView!;
    var infoView: STTagSearchInfoView!;
    var emptySearchView: UIView!;
    var showInfo: Bool = false

    func initEmptyDataSet() {
        let emptyInfoViewNib = Bundle.main.loadNibNamed("STSearchEmptyInfoView", owner: nil, options: nil)
        emptyInfoView = emptyInfoViewNib![0] as! STSearchEmptyInfoView
        emptyInfoView.searchController = self

        let emptySearchViewNib = Bundle.main.loadNibNamed("STSearchEmptyView", owner: nil, options: nil)
        emptySearchView = emptySearchViewNib![0] as! UIView

        let infoViewNib = Bundle.main.loadNibNamed("STTagSearchInfoView", owner: nil, options: nil)
        if isLargerThanSE() {
            infoView = infoViewNib![0] as! STTagSearchInfoView
        } else {
            infoView = infoViewNib![1] as! STTagSearchInfoView
        }
        infoView.searchController = self
    }

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        if case .loaded = state {
            return emptySearchView
        } else if case .empty = state {
            if showInfo {
                return infoView
            } else {
                return emptyInfoView
            }
        } else {
            return nil
        }
    }
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if searchBar.isFirstResponder {
            return false
        } else if case .loading = state {
            return false
        }
        return true
    }


    @objc func dismissKeyboard() {
        if case let .editingQuery(query, tagList, lectureList) = state {
            searchBar.resignFirstResponder()
            searchBar.isEditingTag = false
            if query == nil {
                state = .empty
                FilteredList = []
                searchBar.text = ""
                tagCollectionView.tagList = []
            } else {
                state = .loaded(query!, tagList)
                FilteredList = lectureList
                searchBar.text = query!
                tagCollectionView.tagList = tagList
            }
            reloadData()
            tagCollectionView.reloadData()
            hideTagRecommendation()
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

    

}
