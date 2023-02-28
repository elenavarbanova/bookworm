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
    @IBOutlet weak var starRatingView: CosmosView! {
        didSet {
            configure()
        }
    }
    
    func configure() {
        guard var empty = UIImage(systemName: "star")?.withTintColor(.systemPurple) else { return }
        guard var filled = UIImage(systemName: "star.fill")?.withTintColor(.systemPurple) else { return }
        
        let imageSize = CGSize(width: 30, height: 30)
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        empty = renderer.image { _ in
            empty.draw(in: CGRect(origin: .zero, size: imageSize))
        }
        
        filled = renderer.image { _ in
            filled.draw(in: CGRect(origin: .zero, size: imageSize))
        }
        
        starRatingView.settings.emptyImage = empty
        starRatingView.settings.filledImage = filled
        
    }
}
