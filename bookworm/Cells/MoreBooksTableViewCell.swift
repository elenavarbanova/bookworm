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
    var books = [String: Displayable]()
    var bookIDs = [String]() {
        didSet {
            let countBooks = bookIDs.count
            for book in 0..<countBooks {
                fetchBooks(for: bookIDs[book])
            }
            bookCollectionView.reloadData()
        }
    }
    
    var didSelectItemAction: ((IndexPath, Displayable?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bookId = bookIDs[indexPath.item]
        
        let book = self.books[bookId]
        
        didSelectItemAction?(indexPath, book)
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as! BookCollectionViewCell
        
        let eachBook = bookIDs[indexPath.row]
        cell.titleLabel.text = books[eachBook]?.titleLabelText
        
        cell.coverImageView.image = UIImage(systemName: "book.closed")?.withTintColor(.label /*.systemGray*/, renderingMode: .alwaysTemplate)
        cell.coverImageView.backgroundColor = .systemGray4
        
        if let imageID = books[eachBook]?.image {
            cell.imageID = imageID
            let request = AF.request(imageID, method: .get)
            request.responseImage { response in
                guard let image = response.value else {
                    return
                }
                DispatchQueue.main.async {
                    if cell.imageID == imageID {
                        cell.coverImageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
}

extension MoreBooksTableViewCell {
    func fetchBooks(for searchText: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let request = AF.request("https://openlibrary.org/search.json?q=\(searchText)")
        
        request
            .validate()
            .responseDecodable(of: ResultBooks.self, decoder: decoder) { [weak self] response in
                guard response.error == nil else { return }
                guard let books = response.value else { return }
                
                for book in books.resultBooks {
                    let resultKey = (book.key as NSString).lastPathComponent
                    if resultKey == searchText {
                        self?.books[searchText] = book
                        self?.bookCollectionView.reloadData()
                    }
                }
            }
    }
}
