//
//  STNotificationTableViewCell.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var notification : STNotification! {
        didSet {
            
            let grayAttribute = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.gray]
            let timeText = NSAttributedString(string: notification.createdFrom, attributes: convertToOptionalNSAttributedStringKeyDictionary(grayAttribute))
            var message = NSMutableAttributedString(string: notification.message+" ")
            message.append(timeText)
            descriptionLabel.attributedText = message
            iconImageView.image = notification.image
            if case .Link = notification.type {
                self.selectionStyle = .gray
            } else {
                self.selectionStyle = .none
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.lineBreakMode = .byWordWrapping
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
