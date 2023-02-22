//
//  MoreBooksTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.02.23.
//

import UIKit
import Alamofire
import AlamofireImage

class MoreBooksTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var bookCollectionView: UICollectionView!
    var books = [Displayable]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as! BookCollectionViewCell
        
        let eachBook = books[indexPath.item]
        cell.titleLabel.text = eachBook.titleLabelText
        
        guard let imageID = eachBook.image else {
            return cell
        }

        let request = AF.request(imageID, method: .get)
        request.responseImage { response in
            guard let image = response.value else {
                return
            }
            cell.coverImageView.image = image
        }
        
        return cell
    }
}
