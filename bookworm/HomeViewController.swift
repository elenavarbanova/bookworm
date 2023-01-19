//
//  HomeViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 9.01.23.
//

import UIKit
import Alamofire

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTrendingBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
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
                
                print(books.allBooks.first!)
            }
    }
}
