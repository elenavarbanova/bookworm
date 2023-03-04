//
//  ForYouTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 26.02.23.
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class ForYouTableViewController: UITableViewController {

    let backgroundViewLabel = UILabel(frame: .zero)
    var works = [AuthorWorks]()
    var worksIDs = [String]()
    var recommendedIDs = [String]()
    var recommendedBooks = [String : Displayable]()
    var authorIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableViewBackgroundView()
        getAuthors()
    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        worksIDs.removeAll()
        recommendedBooks.removeAll()
        recommendedIDs.removeAll()
        authorIds.forEach { authorId in
            fetchBooksByAuthor(for: authorId)
        }
        sender.endRefreshing()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendedBooks.count
    }

    func setupTableViewBackgroundView() {
        backgroundViewLabel.textColor = .darkGray
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = "Oops! Browse and add some books to recommend you others!"
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = backgroundViewLabel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell

        let eachBook = recommendedIDs[indexPath.row]
        
        cell.bookTitleLabel?.text = recommendedBooks[eachBook]?.titleLabelText
        cell.authorLabel?.text = recommendedBooks[eachBook]?.subtitleLabelText
        cell.bookCoverImage.image = UIImage(systemName: "book.closed")
        if let imageID = recommendedBooks[eachBook]?.image {
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
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookID = recommendedIDs[indexPath.row]
        let book = recommendedBooks[bookID]
        
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
    
    func getAuthors() {
        let database = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid as? String else {
            return
        }
        database.collection("users").document(userId).collection("authors").getDocuments(completion: { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            
            self?.worksIDs.removeAll()
            self?.works.removeAll()
            for document in querySnapshot!.documents {
                self?.authorIds.append(document.documentID)
                self?.fetchBooksByAuthor(for: document.documentID)
            }
        })
    }
    
    func getIDs() {
        let countBooks = works.count
        for book in 0..<countBooks {
            let workId = (works[book].key as NSString).lastPathComponent
            worksIDs.append(workId)
        }
    }
    
    func getRandomBooks() {
        let books = (works.count / 10) + 1
        
        for _ in 0..<books {
            let randomBook = Int.random(in: 0..<works.count)
            let bookID = worksIDs[randomBook]
            recommendedIDs.append(bookID)
            recommendedBooks[bookID] = nil
            fetchRecommendedBooks(for: bookID)
        }
    }

}

extension ForYouTableViewController {
    func fetchBooksByAuthor(for authorId: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let requestWorks = AF.request("https://openlibrary.org/authors/\(authorId)/works.json?limit=100")
        requestWorks
            .validate()
            .responseDecodable(of: Works.self, decoder: decoder) { [weak self] response in
                guard response.error == nil,
                      let info = response.value else {
                    return
                }

                self?.works = info.entries
                self?.getIDs()
                self?.getRandomBooks()
                self?.tableView.reloadData()
            }
    }
    
    func fetchRecommendedBooks(for searchText: String) {
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
                        self?.recommendedBooks[searchText] = book
                        self?.tableView.reloadData()
                        self?.backgroundViewLabel.isHidden = true
                    }
                }
            }
    }
}
