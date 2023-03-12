//
//  ReadTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 8.02.23.
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class ReadTableViewController: UITableViewController {
    let backgroundViewLabel = UILabel(frame: .zero)
    var bookIds = [String()]
    var readBooks = [String: Displayable]()
    var database = Firestore.firestore()
    var user = Auth.auth().currentUser
    
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
        return readBooks.count
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var bookId = bookIds[indexPath.row]
        
        guard let userId = user?.uid as? String else {
            return nil
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete book") { [weak self] (action, view, completionHandler) in
            
            self?.database.collection("users").document("\(userId)").collection("books").document("\(bookId)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
                completionHandler(true)
                self?.tableView.reloadData()
            }
        }
        deleteAction.backgroundColor = .systemRed
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell

        let eachBook = bookIds[indexPath.row]
        
        cell.bookTitleLabel?.text = readBooks[eachBook]?.titleLabelText
        cell.authorLabel?.text = readBooks[eachBook]?.subtitleLabelText
        cell.bookCoverImage.image = UIImage(systemName: "book.closed")
        if let imageID = readBooks[eachBook]?.image {
            cell.imageID = imageID
            let request = AF.request(imageID, method: .get)
            request.responseImage { response in
                if let image = response.value {
                    DispatchQueue.main.async {
                        if cell.imageID == imageID {
                            cell.bookCoverImage.image = image
                        }
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
        backgroundViewLabel.text = "Oops, it is pretty empty here!"
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = backgroundViewLabel
    }
    
    func getReadBooks() {
        let database = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid as? String else {
            return
        }
        database.collection("users").document(userId).collection("books").whereField("book_state", isEqualTo: BookList.read.rawValue).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            
            self?.bookIds.removeAll()
            self?.readBooks.removeAll()
            for document in querySnapshot!.documents {
                self?.bookIds.append(document.documentID)
                self?.readBooks[document.documentID] = nil
                self?.fetchResultBooks(for: document.documentID)
            }
        }
    }

    
    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookId = bookIds[indexPath.row]
        
        let book = self.readBooks[bookId]
        
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

extension ReadTableViewController {
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
                    let resultKey = (book.key as NSString).lastPathComponent
                    if resultKey == searchText {
                        self?.readBooks[searchText] = book
                        self?.tableView.reloadData()
                        self?.backgroundViewLabel.isHidden = true
                    }
                }
            }
    }
}
