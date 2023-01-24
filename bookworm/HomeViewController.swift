//
//  HomeViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 9.01.23.
//

import UIKit
import Alamofire
import AlamofireImage

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [Displayable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTrendingBooks()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookTableViewCell
        
        let eachBook = items[indexPath.row]
        cell.bookTitleLabel?.text = eachBook.titleLabelText
        cell.authorLabel?.text = eachBook.subtitleLabelText
        
        
        if let imageID = eachBook.image {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    // MARK: - UITableViewDelegate
}


extension HomeViewController {
    func fetchTrendingBooks() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let request = AF.request("https://openlibrary.org/trending/daily.json")
        request
            .validate()
            .responseDecodable(of: Books.self, decoder: decoder) { response in
                guard let books = response.value else { return }
                
                self.items = books.allBooks
                self.tableView.reloadData()
            }
    }
}
