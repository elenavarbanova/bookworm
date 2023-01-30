//
//  ResultBookTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 29.01.23.
//

import UIKit

class ResultBookTableViewCell: UITableViewCell {

    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    var imageID: String?
}
