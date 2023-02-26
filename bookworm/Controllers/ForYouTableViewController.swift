//
//  ForYouTableViewController.swift
//  bookworm
//
//  Created by Elena Varbanova on 26.02.23.
//

import UIKit

class ForYouTableViewController: UITableViewController {

    let backgroundViewLabel = UILabel(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableViewBackgroundView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func setupTableViewBackgroundView() {
        backgroundViewLabel.textColor = .darkGray
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = "Oops! Browse and add some books to recommend you others!"
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = backgroundViewLabel
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
