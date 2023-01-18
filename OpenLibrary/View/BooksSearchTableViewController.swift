//
//  BooksSearchTableViewController.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/10/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit
import CoreData
import Combine

class BooksSearchTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var booksController = BooksController()
    var searchParameter = SearchParameter.title
    var container: PersistentContainer!
    
    var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var cancellable: AnyCancellable?
    
    var searchTask: Task<Void, Error>?
    
    private let bookCoverImage: UIImage! = {
       UIImage(named: "book.cover.placeholder")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(BooksTableViewCell.self, forCellReuseIdentifier: BooksTableViewCell.reuseIdentifier)

        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        title = "Search"
        booksController.delegate = self
        
        view.addSubview(indicatorView)
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        indicatorView.hidesWhenStopped = true
        
        cancellable = NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: searchBar.searchTextField
        )
        .map { notification in
            return (notification.object as! UITextField).text ?? ""
        }
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .sink { [weak self] term in
            
            guard let searchParameter = self?.searchParameter else {
                return
            }
            
            self?.search(term: term, parameter: searchParameter)
        }        
    }
    
    // MARK: - Segment Action
    
    enum Segment: Int {
        case Title, Author
    }
    
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        if let segment = Segment(rawValue: sender.selectedSegmentIndex) {
            switch segment {
            case .Title:
                searchParameter = .title
            case .Author:
                searchParameter = .author
            }
            search(term: searchBar.text ?? "", parameter: searchParameter)
        } else {
            print("Unknown segment value selected")
        }
    }
    
    // MARK: - Search
    
    enum SearchParameter: String {
        case title, author
    }
    
    func search(term: String, parameter: SearchParameter) {
        // Cancel any current search task
        searchTask?.cancel()
        searchTask = nil
        
        if !term.isEmpty { // Avoid searching on the network with emtpy strings
            // Show indicator
            indicatorView.startAnimating()

            let query: [String: String] = [parameter.rawValue: term]
            // Update current search task
            searchTask = Task {
                do {
                    try await booksController.searchLibrary(withQuery: query)
                    tableView.reloadData()
                } catch {
                    print("Search Task Error:", error.localizedDescription)
                }
                indicatorView.stopAnimating()
            }
        } else { // Clear search result when term is empty
            booksController.books.removeAll()
            tableView.reloadData()
        }
    }
    
    // MARK: Tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Pass the selected object to the new view controller.
        
        let bookDetailviewController = UIStoryboard(
            name: "Main",
            bundle: .main)
            .instantiateViewController(identifier: "BookDetailViewController") {
            BookDetailViewController(coder: $0)
        }
        bookDetailviewController.book = booksController.books[indexPath.row]
        bookDetailviewController.container = container
        show(bookDetailviewController, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksController.books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BooksTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! BooksTableViewCell

        // Configure the cell...
        let index = indexPath.row
        guard index < self.booksController.books.count else { return cell }
        
        let book = self.booksController.books[index]
        cell.configure(
            with: book,
            task: Task {
                if let coverID = book.coverID {
                    print("Fetching cover ID: \(coverID) for \(book.title)")
                    let image = try await booksController.fetchCoverImage(coverID: coverID, imageSize: .medium)
                    if cell.book?.coverID == book.coverID {
                        cell.cellImageView.image = image
                    }
                } else {
                    cell.cellImageView.image = bookCoverImage
                }
            }
        )
        return cell
    }
    
    // MARK: Scroll
    // Hides keyboard when user begin scrolling through searched contents
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar != nil {
            searchBar.resignFirstResponder()            
        }
    }
}

// MARK: - EXTENSION

extension BooksSearchTableViewController: UISearchBarDelegate {
    // Performs search when user clicks on the search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let term = searchBar.text {
            search(term: term, parameter: searchParameter)
        }
        // Hides keyboard
        searchBar.resignFirstResponder()
    }
}

extension BooksSearchTableViewController: BooksControllerDelegate {
    func dataReloaded() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}



