//
//  BooksSearchTableViewController.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/10/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit
import Combine

class BooksSearchTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var viewModel = BooksViewModel()
    var searchParameter = SearchParameter.title
    
    var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Stores all bindings
    var cancellables = Set<AnyCancellable>()
    
    var searchTask: Task<Void, Error>?
    
    private let bookCoverImage: UIImage! = {
       UIImage(named: "book.cover.placeholder")
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(BooksTableViewCell.self, forCellReuseIdentifier: BooksTableViewCell.reuseIdentifier)
        
        title = "Search"
        
        view.addSubview(indicatorView)
        indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        indicatorView.hidesWhenStopped = true
        
        // MARK: Bindings
        
        // Create binding between changes in view model's books data and tableview
        viewModel
            .$books
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] books in
                print("books count:", books.count)
                // Updates table view when model changes
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
        
        viewModel
            .$isSearching
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSearching in
                if isSearching {
                    self?.indicatorView.startAnimating()
                } else {
                    self?.indicatorView.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // Create binding between search text to loading new data on view model
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: searchBar.searchTextField
        )
        .map { notification in
            return (notification.object as! UITextField).text ?? ""
        }
        .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
        .sink { [weak self] term in
            
            guard let searchParameter = self?.searchParameter else {
                return
            }
            
            self?.search(term: term, parameter: searchParameter)
        }
        .store(in: &cancellables)
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

            let query: [String: String] = [parameter.rawValue: term]
            // Update current search task
            searchTask = Task {
                do {
                    try await viewModel.searchLibrary(withQuery: query)
                } catch {
                    print("Search Task Error:", error.localizedDescription)
                }
            }
        } else { // Clear search result when term is empty
            viewModel.clearBooks()
        }
    }
    
    // MARK: Tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Pass the selected object to the new view controller.
        let model = self.viewModel
        let books = model.books
        
        guard indexPath.row < books.count else {
            return
        }
        
        let bookDetailviewController = UIStoryboard(
            name: "Main",
            bundle: .main)
            .instantiateViewController(identifier: "BookDetailViewController") {
                BookDetailViewController(coder: $0, book: model.books[indexPath.row], viewModel: model)
        }
        bookDetailviewController.viewModel = self.viewModel
        show(bookDetailviewController, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BooksTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! BooksTableViewCell

        // Configure the cell...
        let index = indexPath.row
        guard index < self.viewModel.books.count else { return cell }
        
        let book = self.viewModel.books[index]
        
        // Sets background color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.red
        cell.selectedBackgroundView = bgColorView
        
        // Configure the rest of the cell, including fetching cover image
        cell.configure(
            with: book,
            task: Task {
                if let coverID = book.coverID {
                    print("Fetching cover ID: \(coverID) for \(book.title)")
                    let image = try await viewModel.fetchCoverImage(coverID: coverID, imageSize: .medium)
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


