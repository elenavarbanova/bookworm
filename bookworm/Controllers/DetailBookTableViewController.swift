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
    var reviews = [Review]()
    var comments = [Review]()
    var stars = 0.0
    var textComment = String()
    var user = Auth.auth().currentUser
    let activityIndicator = UIActivityIndicatorView(frame: .zero)
    var stateBook = 0
    var nicknames: [String: String] = [:]
    
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
        case Review = 4
        case Comments = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = book?.titleLabelText
        setupTableViewBackgroundView()
        fetchBookInfo()
        tableView.reloadData()
        getReviews()
        getBookStatus()
        getNicknames()
    }
    
    func setupTableViewBackgroundView() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        tableView.backgroundView = activityIndicator
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if infoBook.isEmpty {
            return 0
        }
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Sections.Comments.rawValue {
            return comments.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Sections.Description.rawValue {
            return "Description"
        } else if section == Sections.Subjects.rawValue {
            return "Subjects"
        } else if section == Sections.Review.rawValue {
            return "Leave a review"
        } else if section == Sections.Comments.rawValue {
            return "Comments"
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !infoBook.isEmpty {
            if indexPath.section == Sections.Header.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Header", for: indexPath) as! HeaderTableViewCell
                
                if cell.authorBookStackView.subviews.count != 0 {
                    for authorView in cell.authorBookStackView.subviews {
                        cell.authorBookStackView.removeArrangedSubview(authorView)
                        authorView.removeFromSuperview()
                    }
                }
                
                if cell.addBookStackView.subviews.count != 0 {
                    cell.addBookStackView.subviews.forEach { addBookView in
                        cell.addBookStackView.removeArrangedSubview(addBookView)
                        addBookView.removeFromSuperview()
                    }
                }
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
                
                cell.coverImage.image = UIImage(systemName: "book.closed")
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
                let pages = "\(String(describing: infoBook[0].numberOfPagesMedian!))" // crash, fix with if let
                cell.pagesLabel.text = pages
                let editions = "\(String(describing: infoBook[0].editionCount))"
                cell.editionsLabel.text = editions
                let languages = "\(String(describing: infoBook[0].language!.count))"
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
                

                guard let subjects = infoBook[0].subject else {
                    return cell
                }
                
                let countSubjects = subjects.count
                
                if cell.subjectsStackView.subviews.count != 0 {
                    for button in cell.subjectsStackView.subviews {
                        cell.subjectsStackView.removeArrangedSubview(button)
                        button.removeFromSuperview()
                    }
                }
                
                for subject in 0..<countSubjects {
                    createSubjectButton(for: subjects[subject], for: cell)
                }
                return cell
            } else if indexPath.section == Sections.Review.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Review", for: indexPath) as! ReviewTableViewCell
                cell.starRatingView.didFinishTouchingCosmos = { rating in
                    self.stars = rating
                }
                cell.textChanged {[weak tableView] (newText: String) in
                    self.textComment = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                 }
                if textComment.count > 0 {
                    cell.commentTextView.text = textComment
                }
                return cell
            } else if indexPath.section == Sections.Comments.rawValue{
                let comment = comments[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "Comments", for: indexPath) as! CommentsTableViewCell
                if comment.userId == "Unknown" {
                    cell.userLabel.text = "Unknown author"
                } else {
                    cell.userLabel.text = nicknames[comment.userId]
                }
                cell.commentLabel.text = comment.comment
                
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .abbreviated
                formatter.maximumUnitCount = 1
                if let formatted = formatter.string(from: comment.date, to: Date()) {
                    cell.dateLabel.text = "\(formatted) ago"
                }
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
    func getReviews() {
        guard let bookId = (book?.key as? NSString)?.lastPathComponent else {
            return
        }
        database.collection("books").document(bookId).collection("reviews").order(by: "date", descending: true).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            self?.reviews.removeAll()
            self?.comments.removeAll()
            for document in querySnapshot!.documents {
                let review = Review(aDoc: document)
                self?.reviews.append(review)
                guard let comment = review.comment else {
                    continue
                }
               if !comment.isEmpty {
                   self?.comments.append(review)
                }
            }
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - Get user nickname
    func getNicknames() {
        database.collection("users").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(String(describing: error))")
                return
            }
            self?.nicknames.removeAll()
            for document in querySnapshot!.documents {
                let nickname = Nickname(aDoc: document)
                self?.nicknames[document.documentID] = nickname.userNickname
            }
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - Create buttons
    func createSubjectButton(for title: String, for cell: SubjectsTableViewCell) {
        let button = UIButton(type: .system)
        button.configuration = .plain()

        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemPurple, for: .normal)
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

        button.setTitleColor(.systemPurple, for: .normal)
        button.addTarget(self, action: #selector(authorButtonTapped(_:)), for: .touchUpInside)
        
        cell.authorBookStackView.addArrangedSubview(button)
    }
    
    func createAddBookButton(for cell: HeaderTableViewCell) {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemPurple
        
        if stateBook != 0 {
            config.title = "Added"
        } else {
            config.title = "Add Book"
        }
        
        let button = UIButton()
        button.showsMenuAsPrimaryAction = true
        button.configuration = config
    
        
        let TBRAction = UIAction(title: "TBR", handler: { [weak self] action in
            self?.addBook(list: .tbr)
            self?.addAuthor()
            config.title = "Added"
            button.configuration = config
        })
        
        let CRAction = UIAction(title: "Currently reading", handler: { [weak self] action in
            self?.addBook(list: .reading)
            self?.addAuthor()
            config.title = "Added"
            button.configuration = config
        })
        
        let ReadAction = UIAction(title: "Read", handler: { [weak self] action in
            self?.addBook(list: .read)
            self?.addAuthor()
            config.title = "Added"
            button.configuration = config
        })
        
        
        button.menu = UIMenu(children: [
            TBRAction,
            CRAction,
            ReadAction
        ])
        
        button.frame = CGRect(x: cell.addBookStackView.frame.midX/2, y: cell.addBookStackView.frame.midY/2, width: 100, height: 25)
        cell.addBookStackView.addSubview(button)
    }
    
    func getBookStatus() {
        guard let userId = user?.uid as? String,
              let bookId = (book?.key as? NSString)?.lastPathComponent else {
            return
        }
        database.collection("users").document(userId).collection("books").getDocuments { (querySnapshot, err) in
            guard err == nil else {
                print("Error getting documents: \(String(describing: err))")
                return
            }
            
            querySnapshot?.documents.forEach({ document in
                if document.documentID == bookId {
                    self.stateBook = document.data()["book_state"] as! Int
                }
            })
            self.tableView.reloadData()
        }
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
            let authorID = (authorIDs[auth] as NSString).lastPathComponent
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
        guard let userId = user?.uid as? String,
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
        
        guard let userId = user?.uid as? String,
              let bookId = (book?.key as? NSString)?.lastPathComponent else {
            return
        }

        self.database.collection("books").document("\(bookId)").collection("reviews").document("\(userId)").setData([
            "comment":textComment,
            "date":dateNow,
            "user_id":userId,
            "rating":stars
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        cell?.starRatingView.rating = 0
        cell?.commentTextView.text?.removeAll()
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
                
                self.activityIndicator.stopAnimating()
                
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
