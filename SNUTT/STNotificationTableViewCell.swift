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
            
            let grayAttribute = [NSAttributedString.Key.foregroundColor: UIColor.gray]
            let timeText = NSAttributedString(string: notification.createdFrom, attributes: grayAttribute)
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
