//
//  DetailBookViewControllerTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 20.02.23.
//

import UIKit
import Alamofire
import AlamofireImage
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class DetailBookTableViewController: UITableViewController {
    

    //MARK: 
    var imageID: String?
    var book: Displayable? = nil
    var infoBook = [InfoBook]()
    var descriptionBook = String()
    var authors: [String: String] = [:]
    var database = Firestore.firestore()
    var comments = [Comment]()
    var stars = 0.0
    
    //MARK: - Enums
    enum BookList: Int {
    case tbr = 1
    case reading = 2
    case read = 3
    }
    
    enum Sections: Int, CaseIterable {
        case Header = 0
        case Details = 1
        case Description = 2
        case Subjects = 3
        case MoreBooks = 4
        case Review = 5
        case Comments = 6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = book?.titleLabelText
        fetchBookInfo()
        tableView.reloadData()
        getComments()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == Sections.Comments.rawValue {
            return comments.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !infoBook.isEmpty {
            if indexPath.section == Sections.Header.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Header", for: indexPath) as! HeaderTableViewCell
                
                createAddBookButton(for: cell)
                guard let authorNames = book?.authorNames else {
                    return cell
                }
                
                let countNames = authorNames.count
                
                for auth in 0..<countNames {
                    authors[authorNames[auth]] = book?.authorKeys?[auth]
                    createAuthorButton(for: authorNames[auth], for: cell)
                }
                
                guard let url = imageID else { return cell }
                
                let request = AF.request(url, method: .get)
                request.responseImage { response in
                    if let image = response.value {
                        DispatchQueue.main.async {
                            cell.coverImage.image = image
                        }
                    }
                }
                return cell
            } else if indexPath.section == Sections.Details.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Details", for: indexPath) as! DetailsTableViewCell
                let year = "\(String(describing: infoBook[0].firstPublishYear))"
                cell.publishedLabel.text = year
                let pages = "\(String(describing: infoBook[0].numberOfPagesMedian)) pages"
                cell.pagesLabel.text = pages
                let editions = "\(String(describing: infoBook[0].editionCount)) editions"
                cell.editionsLabel.text = editions
                let languages = "\(String(describing: infoBook[0].language!.count)) languages"
                cell.languagesLabel.text = languages
                return cell
            } else if indexPath.section == Sections.Description.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Description", for: indexPath) as! DescriptionTableViewCell
                if descriptionBook.isEmpty {
                    cell.descriptionLabel.text = "This book does not have a description yet."
                } else {
                    cell.descriptionLabel.text = descriptionBook
                }
                return cell
            } else if indexPath.section == Sections.Subjects.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Subjects", for: indexPath) as! SubjectsTableViewCell
                let countSubjects = infoBook[0].subject.count
                
                for subject in 0..<countSubjects {
                    createSubjectButton(for: infoBook[0].subject[subject], for: cell)
                }
                return cell
            } else if indexPath.section == Sections.MoreBooks.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MoreBooks", for: indexPath) as! MoreBooksTableViewCell
                
                return cell
            } else if indexPath.section == Sections.Review.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Review", for: indexPath) as! ReviewTableViewCell
                cell.starRatingView.didFinishTouchingCosmos = { rating in
                    self.stars = rating
                }
//                cell.starRatingView.settings.emptyImage = UIImage
                return cell
            } else if indexPath.section == Sections.Comments.rawValue{
                let comment = comments[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "Comments", for: indexPath) as! CommentsTableViewCell
                cell.commentLabel.text = comment.comment
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"

                let date = comment.date
                let dateString = dateFormatter.string(from: date)
                cell.dateLabel.text = dateString
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "SubjectSegue",
              let destination = segue.destination as? SubjectTableViewController,
              let button = sender as? UIButton,
              let subject = button.currentTitle {
            destination.subject = subject
        } else {
            
            guard let destination = segue.destination as? DetailAuthorTableViewController,
                  let button = sender as? UIButton,
                  let authorName = button.currentTitle else {
                return
            }
            
            destination.author = authors[authorName]!
            destination.authorName = authorName
        }
    }
    
    
    //MARK: - Get comments
    func getComments() {
        guard let bookId = (book?.key as? NSString)?.lastPathComponent else {
            return
        }
        database.collection("books").document(bookId).collection("reviews").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            for document in querySnapshot!.documents {
                let comment = Comment(aDoc: document)
                self?.comments.append(comment)
            }
        }
    }
    
    //MARK: - Create buttons
    func createSubjectButton(for title: String, for cell: SubjectsTableViewCell) {
        let button = UIButton(type: .system)
        button.configuration = .plain()

        button.setTitle(title, for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.addTarget(self, action: #selector(subjectButtonTapped(_:)), for: .touchUpInside)
        
        cell.subjectsStackView.addArrangedSubview(button)
    }
    
    func createAuthorButton(for title: String, for cell: HeaderTableViewCell) {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        
        if title == "Unknown author" {
            button.setTitle(title, for: .disabled)
        } else {
            button.setTitle(title, for: .normal)
        }

        button.setTitleColor(.purple, for: .normal)
        button.addTarget(self, action: #selector(authorButtonTapped(_:)), for: .touchUpInside)
        
        cell.authorBookStackView.addArrangedSubview(button)
    }
    
    func createAddBookButton(for cell: HeaderTableViewCell) {
        var config = UIButton.Configuration.filled()
        config.title = "Add Book"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemPurple
        
        let button = UIButton()
        button.showsMenuAsPrimaryAction = true
        button.configuration = config
        
        let TBRAction = UIAction(title: "TBR", handler: { [weak self] action in
            self?.addBook(list: .tbr)
            self?.addAuthor()
        })
        
        let CRAction = UIAction(title: "Currently reading", handler: { [weak self] action in
            self?.addBook(list: .reading)
            self?.addAuthor()
        })
        
        let ReadAction = UIAction(title: "Read", handler: { [weak self] action in
            self?.addBook(list: .read)
            self?.addAuthor()
        })
        
//        action.image = UIImage(systemName: "checkmark")
        
        button.menu = UIMenu(children: [
            TBRAction,
            CRAction,
            ReadAction
        ])
        
        button.frame = CGRect(x: cell.addBookStackView.frame.midX, y: cell.addBookStackView.frame.midY, width: 100, height: 25)
            
        cell.addBookStackView.addSubview(button)
    }
    
    func addAuthor() {
        guard let userId = Auth.auth().currentUser?.uid as? String else {
            return
        }
        
        guard let authorIDs = book?.authorKeys else {
            return
        }
        
        let countIDs = authorIDs.count
        
        for auth in 0..<countIDs {
            guard let authorID = (authorIDs[auth] as? NSString)?.lastPathComponent else {
                continue
            }
            database.collection("users/").document("\(userId)").collection("authors").document("\(authorID)").setData([:]) { err in
                guard err == nil else {
                    print("Error writing document: \(String(describing: err))")
                    return
                }
                print("Author successfully added!")
            }
        }
    }
    
    //MARK: - Add book to user's books
    func addBook(list: BookList) {
        guard let userId = Auth.auth().currentUser?.uid as? String,
              let bookId = (book?.key as? NSString)?.lastPathComponent else {
            return
        }
        
        let dateNow = Date.now
        
        database.collection("users/").document("\(userId)").collection("books").document("\(bookId)").setData(["book_state":list.rawValue, "date_created":dateNow]) { err in
            guard err == nil else {
                print("Error writing document: \(String(describing: err))")
                return
            }
            print("Document successfully written!")
        }
    }
    
    //MARK: - Buttons action
    @objc func authorButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "authorInfoSegue", sender: sender)
    }
    
    @objc func subjectButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SubjectSegue", sender: sender)
    }

    @IBAction func commentButtonTapped(_ sender: Any) {

        let dateNow = Date.now
        
        let indexPath = IndexPath(row: 0, section: Sections.Review.rawValue)
        let cell = tableView.cellForRow(at: indexPath) as? ReviewTableViewCell
        
        guard let comment = cell?.commentTextField.text?.trimmingCharacters(in: .whitespaces),
//              let userName = Auth.auth().currentUser?.displayName as? String,
              let bookId = (book?.key as? NSString)?.lastPathComponent else {
            return
        }

        self.database.collection("books").document("\(bookId)").collection("reviews").addDocument(data: [
                "comment":comment,
                "date":dateNow,
//                "user_name":userName
                "rating":stars
            ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        cell?.starRatingView.rating = 0
        cell?.commentTextField.text?.removeAll()
    }
}

extension DetailBookTableViewController {
    func fetchBookInfo() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let bookId = (book?.key as? NSString)?.lastPathComponent else { return }
        
        let request = AF.request("https://openlibrary.org/search.json?q=\(bookId)")
        request
            .validate()
            .responseDecodable(of: ResultInfoBook.self, decoder: decoder) { response in
                guard response.error == nil,
                      let info = response.value else {
                    return
                }
                
                self.infoBook = info.docs
                self.tableView.reloadData()
            }
        
        let descriptionRequest = AF.request("https://openlibrary.org/works/\(bookId).json")
        descriptionRequest
            .validate()
            .responseDecodable(of: DescriptionBook.self, decoder: decoder) { [weak self] response in
                guard response.error == nil else {
                    return
                }
                guard let description = response.value else { return }
                
                self?.descriptionBook = description.description.value
                self?.tableView.reloadData()
            }
    }
}
