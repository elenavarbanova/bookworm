//
//  BookCollectionViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.02.23.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    var imageID: String?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        titleLabel.text = nil
    }
}
