//
//  ReviewTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.02.23.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var starRatingView: CosmosView!
}
