//
//  ReviewTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.02.23.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var starRatingView: CosmosView! {
        didSet {
            configure()
        }
    }
    
    var textChanged: ((String) -> Void)?
        
    var placeholderShown = true {
        didSet {
            if placeholderShown {
                commentTextView.text = "Type your thoughts here..."
                commentTextView.textColor = .systemGray3
            } else {
                commentTextView.text = ""
                commentTextView.textColor = .label
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        placeholderShown = true
        commentTextView.delegate = self
        commentTextView.layer.cornerRadius = 5
        commentTextView.layer.borderWidth = 1/3
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        commentTextView.clipsToBounds = true
    }
        
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
        
    func textViewDidChange(_ textView: UITextView) {
        if !placeholderShown {
            textChanged?(textView.text)
        }
        if textView.text.count == 0 {
            placeholderShown = true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if placeholderShown {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if placeholderShown {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if placeholderShown {
            placeholderShown = false
        }
        return true
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        placeholderShown = true
        textChanged = nil
    }
}
