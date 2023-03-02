//
//  CommentsTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.02.23.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userLabel.text = nil
        dateLabel.text = nil
        commentLabel.text = nil
    }
}
