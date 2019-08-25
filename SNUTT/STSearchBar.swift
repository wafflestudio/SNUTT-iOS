//
//  STSearchBar.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 1..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STSearchBar: UISearchBar, UISearchBarDelegate{
    
    weak var searchController : STLectureSearchTableViewController!
    var queryString : String = ""
    
    var isEditingTag : Bool = false {
        didSet {
            if isEditingTag {
                self.returnKeyType = .done
                self.reloadInputViews()
                self.setImage(UIImage(named: "icon_tag_gray"), for: .search, state: UIControl.State())
                searchController.searchToolbarView.setEditingTag(true)
            } else {
                self.returnKeyType = .search
                self.reloadInputViews()
                self.setImage(nil, for: .search, state: UIControl.State())
                searchController.searchToolbarView.setEditingTag(false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.keyboardType = .default
        self.returnKeyType = .search
        self.enablesReturnKeyAutomatically = false
        self.tintColor = UIColor.black
    }
    
    func disableEditingTag() {
        if (isEditingTag) {
            isEditingTag = false
            self.text = queryString
            queryString = ""
            searchController.hideTagRecommendation()
        }
    }
    
    func enableEditingTag() {
        if (!isEditingTag) {
            queryString = self.text!
            self.text = "";
            isEditingTag = true
            self.searchBar(self, textDidChange: self.text!)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isEditingTag {
            isEditingTag = false
            self.text = queryString
            queryString = ""
            searchController.hideTagRecommendation()
        } else {
            searchController.searchBarCancelButtonClicked()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if isEditingTag {
            if text.contains("#") {
                let replacement = text.replacingOccurrences(of: "#", with: "")
                self.text!.replaceSubrange(STUtil.getRangeFromNSRange(self.text!, range: range), with: replacement)
                self.searchBar(self, textDidChange: self.text!)
                return false
            }
            return true
        } else {
            if text == "#" {
                queryString = self.text!
                queryString.replaceSubrange(STUtil.getRangeFromNSRange(queryString, range: range), with: "")
                self.text = "";
                isEditingTag = true
                self.searchBar(self, textDidChange: self.text!)
                return false
            } else if text.contains("#") {
                let replacement = text.replacingOccurrences(of: "#", with: "")
                self.text!.replaceSubrange(STUtil.getRangeFromNSRange(self.text!, range: range), with: replacement)
                self.searchBar(self, textDidChange: self.text!)
                return false
            }
            return true
        }
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchBar.isFirstResponder {
            // this is only for the case of clicking clear button while not in focus
            // searchController.state = .empty
            return
        }
        
        if isEditingTag {
            searchController.showTagRecommendation()
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.showsCancelButton = true
        if case .loaded(let query, let tagList) = searchController.state {
            searchController.state = .editingQuery(query, tagList, searchController.FilteredList)
        } else {
             if case .loading(let request) = searchController.state {
                request.dispose()
            }
            searchController.state = .editingQuery(nil, [], [])
        }
        searchController.reloadData()
        searchController.tableView.reloadEmptyDataSet()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.showsCancelButton = false
        searchController.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isEditingTag {
            if searchController.tagTableView.filteredList.count != 0 {
                searchController.tagTableView.addTagAtIndex(0)
            }
        } else {
            self.resignFirstResponder()
            searchController.searchBarSearchButtonClicked(self.text!)
        }
        
    }
    
}
