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

class MyBooksTableViewController: UITableViewController {
    let backgroundViewLabel = UILabel(frame: .zero)
    var tbrBookIds = [String]()
    var readingBookIds = [String]()
    var tbrBooks = [String: Displayable]()
    var readingBooks = [String: Displayable]()
    
    enum BookList: Int {
    case tbr = 1
    case reading = 2
    case read = 3
    }
    
    enum Sections: Int, CaseIterable {
        case Reading = 0
        case TBR = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableViewBackgroundView()
        getTBRBooks()
        getReadingBooks()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Sections.Reading.rawValue {
            return readingBooks.count
        }
        return tbrBooks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell

        var book: Displayable?
        if indexPath.section == Sections.Reading.rawValue {
            let eachBook = readingBookIds[indexPath.row]
            book = readingBooks[eachBook]
        } else {
            let eachBook = tbrBookIds[indexPath.row]
            book = tbrBooks[eachBook]
        }
        
        cell.bookTitleLabel?.text = book?.titleLabelText
        cell.authorLabel?.text = book?.subtitleLabelText
        
        if let imageID = book?.image {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Sections.Reading.rawValue {
            return "Reading"
        }
        return "TBR"
    }
    
    func setupTableViewBackgroundView() {
        backgroundViewLabel.textColor = .darkGray
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = "Oops, it is pretty empty here! Add books"
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = backgroundViewLabel
    }
    
    func getTBRBooks() {
        let database = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid as? String else {
            return
        }
        database.collection("users").document(userId).collection("books").whereField("book_state", isEqualTo: BookList.tbr.rawValue).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            self?.tbrBooks.removeAll()
            self?.tbrBookIds.removeAll()
            for document in querySnapshot!.documents {
                self?.tbrBookIds.append(document.documentID)
                self?.tbrBooks[document.documentID] = nil
                self?.fetchTBRResultBooks(for: document.documentID)
            }
        }
    }

    func getReadingBooks() {
        let database = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid as? String else {
            return
        }
        database.collection("users").document(userId).collection("books").whereField("book_state", isEqualTo: BookList.reading.rawValue).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            self?.readingBooks.removeAll()
            self?.readingBookIds.removeAll()
            for document in querySnapshot!.documents {
                self?.readingBookIds.append(document.documentID)
                self?.readingBooks[document.documentID] = nil
                self?.fetchReadingResultBooks(for: document.documentID)
            }
        }
    }

    
    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book: Displayable?
        if indexPath.section == Sections.Reading.rawValue {
            let bookId = readingBookIds[indexPath.row]
            book = self.readingBooks[bookId]
        } else {
            let bookId = tbrBookIds[indexPath.row]
            book = self.tbrBooks[bookId]
        }
        
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

extension MyBooksTableViewController {
    func fetchTBRResultBooks(for searchText: String) {
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
    
    func fetchReadingResultBooks(for searchText: String) {
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
                        self?.readingBooks[searchText] = book
                        self?.tableView.reloadData()
                        self?.backgroundViewLabel.isHidden = true
                    }
                }
            }
    }
}
