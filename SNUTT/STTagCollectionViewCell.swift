//
//  STTagCollectionViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    weak var collectionView : STTagCollectionView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var searchTag : STTag! {
        didSet {
            tagLabel.text = searchTag.text
            containerView.backgroundColor = searchTag.type.tagLightColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.addGestureRecognizer(tap)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setSize()
    }

    func setSize() {
        if isLargerThanSE() {
            heightConstraint.constant = 30.0
            tagLabel.font = UIFont.systemFont(ofSize: 15.0)
        } else {
            heightConstraint.constant = 28.0
            tagLabel.font = UIFont.systemFont(ofSize: 14.0)
        }
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.ended {
            deleteTag()
        }
    }
    
    func deleteTag() {
        let indexPath = self.collectionView.indexPath(for: self)!
        collectionView.tagList.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        collectionView.setHidden()
        collectionView.searchController.searchBar.becomeFirstResponder()
    }
    
}
