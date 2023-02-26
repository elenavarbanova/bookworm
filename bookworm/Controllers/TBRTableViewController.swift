//
//  TBRTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 7.02.23.
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class TBRTableViewController: UITableViewController {
    let backgroundViewLabel = UILabel(frame: .zero)
    var bookIds = [String]()
    var tbrBooks = [String: Displayable]()
    
    enum BookList: Int {
    case tbr = 1
    case reading = 2
    case read = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableViewBackgroundView()
        getReadBooks()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tbrBooks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell

        let eachBook = bookIds[indexPath.row]
        
        cell.bookTitleLabel?.text = tbrBooks[eachBook]?.titleLabelText
        cell.authorLabel?.text = tbrBooks[eachBook]?.subtitleLabelText
        
        if let imageID = tbrBooks[eachBook]?.image {
            cell.imageID = imageID
            let request = AF.request(imageID, method: .get)
            request.responseImage { response in
                guard let image = response.value else {
                    return
                }
                DispatchQueue.main.async {
                    if cell.imageID == imageID {
                        cell.bookCoverImage.image = image
                    }
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func setupTableViewBackgroundView() {
        backgroundViewLabel.textColor = .darkGray
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = "Oops, it is pretty empty here! Add books"
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = backgroundViewLabel
    }
    
    func getReadBooks() {
        let database = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid as? String else {
            return
        }
        database.collection("users").document(userId).collection("books").whereField("book_state", isEqualTo: BookList.tbr.rawValue).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            for document in querySnapshot!.documents {
                self?.bookIds.append(document.documentID)
                self?.tbrBooks[document.documentID] = nil
                self?.fetchResultBooks(for: document.documentID)
            }
        }
    }


    
    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookId = bookIds[indexPath.row]
        
        let book = self.tbrBooks[bookId]
        
        performSegue(withIdentifier: "DetailBookSegue", sender: book)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "DetailBookSegue",
              let destination = segue.destination as? DetailBookTableViewController,
              let book = sender as? Displayable else {
            return
        }
        
        destination.book = book
        destination.imageID = book.image
    }
    
}

extension TBRTableViewController {
    func fetchResultBooks(for searchText: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let request = AF.request("https://openlibrary.org/search.json?q=\(searchText)")
        
        request
            .validate()
            .responseDecodable(of: ResultBooks.self, decoder: decoder) { [weak self] response in
                guard response.error == nil else { return }
                guard let books = response.value else { return }
                
                for book in books.resultBooks {
                    guard let resultKey = (book.key as? NSString)?.lastPathComponent else { continue }
                    if resultKey == searchText {
                        self?.tbrBooks[searchText] = book
                        self?.tableView.reloadData()
                        self?.backgroundViewLabel.isHidden = true
                    }
                }
            }   
    }
}