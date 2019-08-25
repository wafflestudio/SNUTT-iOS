//
//  STLectureSearchToolbarView.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 4..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STLectureSearchToolbarView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var searchTableViewController: STLectureSearchTableViewController!

    @IBOutlet weak var sharpButtonLabel: UILabel!
    @IBOutlet weak var sharpButton: STViewButton!
    
    @IBOutlet weak var emptyTimeLabel: UILabel!
    @IBOutlet weak var emptyTimeButton: STViewButton!
    @IBOutlet weak var tagFilterCollectionView: UICollectionView!
    var isEditingTag: Bool {
        return searchTableViewController.searchBar.isEditingTag
    }
    var isEmptyTime: Bool = false;
    var sizingCell : STTagFilterCollectionViewCell!
    
    var tagTypeList : [STTagType] = []
    var currentTagType: STTagType?
    
    override func awakeFromNib() {
        tagFilterCollectionView.delegate = self
        tagFilterCollectionView.dataSource = self
        let nib = UINib(nibName: "STTagFilterCollectionViewCell", bundle: nil)
        tagFilterCollectionView.register(nib, forCellWithReuseIdentifier: "STTagFilterCollectionViewCell")
        sizingCell = nib.instantiate(withOwner: self, options: nil)[0] as! STTagFilterCollectionViewCell
        tagTypeList = [.AcademicYear, .Classification, .Credit, .Department, .Instructor, .Category]
        sharpButton.buttonPressAction = {
            self.sharpButtonClicked()
        }
        emptyTimeButton.buttonPressAction = {
            self.emptyTimeButtonClicked()
        }
        
        setEditingTag(false)
        setEmptyButton()
        
    }
    
    func sharpButtonClicked() {
        if isEditingTag {
            searchTableViewController.searchBar.disableEditingTag()
        } else {
            searchTableViewController.searchBar.enableEditingTag()
        }
    }
    func emptyTimeButtonClicked() {
        isEmptyTime = !isEmptyTime
        setEmptyButton()
    }
    func setEmptyButton() {
        if isEmptyTime {
            emptyTimeLabel.textColor = UIColor.black
            emptyTimeLabel.text = "ON"
        } else {
            emptyTimeLabel.textColor = UIColor(white: 0.7, alpha: 1.0)
            emptyTimeLabel.text = "OFF"
        }
    }
    
    func setEditingTag(_ editingTag: Bool) {

        if editingTag {
            sharpButtonLabel.text = "취소"
            sharpButton.layoutIfNeeded()
            emptyTimeButton.isHidden = true
            tagFilterCollectionView.isHidden = false
        } else {
            sharpButtonLabel.text = "#태그"
            sharpButton.layoutIfNeeded()
            emptyTimeButton.isHidden = false
            tagFilterCollectionView.isHidden = true
        }
    }
    
    //MARK: UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizingCell.tagType = tagTypeList[indexPath.row]
        return sizingCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: UILayoutPriority(rawValue: Float(self.frame.width)), verticalFittingPriority: UILayoutPriority(rawValue: 42))
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagTypeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "STTagFilterCollectionViewCell", for: indexPath) as! STTagFilterCollectionViewCell
        cell.tagType = tagTypeList[indexPath.row]
        cell.isSelectedTag = tagTypeList[indexPath.row] == currentTagType
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTagType = tagTypeList[indexPath.row]
        let curTagRow = currentTagType == nil ? nil : tagTypeList.index(of: currentTagType!)
        if selectedTagType == currentTagType {
            currentTagType = nil
        } else {
            currentTagType = selectedTagType
        }
        var reloadIndexPaths = [indexPath]
        if let row = curTagRow {
            if row != indexPath.row {
                reloadIndexPaths.append(IndexPath(row: row, section: 0))
            }
        }
        collectionView.reloadItems(at: reloadIndexPaths)
        searchTableViewController.showTagRecommendation()
    }

}
