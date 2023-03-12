//
//  HeaderTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.02.23.
//

import UIKit
import Cosmos

class HeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addBookStackView: UIStackView!
    @IBOutlet weak var coverImage: UIImageView! {
        didSet {
            coverImage.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var authorBookStackView: UIStackView!
    @IBOutlet weak var ratingView: UIStackView!
    @IBOutlet weak var overallRating: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var comments: UILabel!
    
}
