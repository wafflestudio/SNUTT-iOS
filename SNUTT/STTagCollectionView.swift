//
//  STTagCollectionView.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTagCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var tagList : [STTag] = []
    weak var searchController : STLectureSearchTableViewController!
    var sizingCell : STTagCollectionViewCell!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        (self.collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing = 10.0
        let nib = UINib(nibName: "STTagCollectionViewCell", bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: "STTagCollectionViewCell")
        sizingCell = nib.instantiate(withOwner: self, options: nil)[0] as! STTagCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizingCell.searchTag = tagList[indexPath.row]
        return sizingCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: UILayoutPriority(rawValue: Float(self.frame.width)), verticalFittingPriority: UILayoutPriority(rawValue: 27))
    }
    
    func hide() {
        searchController.tagCollectionViewConstraint.priority = UILayoutPriority(rawValue: 700)
        UIView.animate(withDuration: 0.2, animations:{
            self.layoutIfNeeded()
            self.searchController.tagTableView.contentInset.top = 5
            self.searchController.tagTableView.layoutIfNeeded()
        })
    }
    
    func show() {
        searchController.tagCollectionViewConstraint.priority = UILayoutPriority(rawValue: 800)
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
            self.searchController.tagTableView.contentInset.top = -2
        })
    }
    
    func setHidden() {
        if tagList.count == 0 {
            hide()
        } else {
            show()
        }
    }
    
    override func reloadData() {
        setHidden()
        super.reloadData()
    }
    
    override var numberOfSections : Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "STTagCollectionViewCell", for: indexPath) as! STTagCollectionViewCell
        cell.layer.cornerRadius = cell.frame.height / 2.0
        cell.searchTag = tagList[indexPath.row]
        cell.collectionView = self
        cell.contentView.addSubview(cell.containerView)
        return cell
    }

}
