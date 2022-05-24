//
//  WishlistTableViewController.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/14/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit
import CoreData

class WishlistTableViewController: UITableViewController {
    
    var container: PersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<BookModel>!
    var booksController: BooksController = BooksController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        title = "Wishlist"
        
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
        
        initializeFetchedResultsController()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BooksTableViewCell
        
        // Configure the cell...
        configure(cell, forBookAt: indexPath)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
     */
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let context = container.viewContext
            let bookModel = fetchedResultsController.object(at: indexPath)
            context.delete(bookModel)
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // MARK: Configuration
    func configure(_ cell: BooksTableViewCell, forBookAt indexPath: IndexPath) {

        
        let book = fetchedResultsController.object(at: indexPath)
        // reset cell's label and image
        cell.titleLabel.text = ""
        cell.authorLabel?.text = ""
        let imageView = cell.cellImageView
        imageView?.image = UIImage(named: "gray")


        cell.titleLabel.text = book.title
        if let author = book.author {
            cell.authorLabel.text = author
        }
        let coverID = Int(book.coverID)
        booksController.fetchCoverImage(coverID: coverID, imageSize: .medium) { (image) in
            if let coverImage = image {
                DispatchQueue.main.async {
                    // Switches to main queue to update image
                    imageView?.image = coverImage
                    // Resize imageview to aspect fill
                    imageView?.contentMode = .scaleAspectFill
                }
            }
        }
        

    }
    
    // MARK: - Add Wishlist
    @IBAction func addWishlistButtonTapped(_ sender: Any) {
        // TODO: To implement modal search table view with quick add-button to add to wishlist
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let wishlistDetailViewController = segue.destination as? WishlistDetailViewController,
            let indexPath = tableView?.indexPathForSelectedRow
            else { return }
        let bookModel = fetchedResultsController.object(at: indexPath)
        wishlistDetailViewController.bookModel = bookModel
    }

}

// MARK: - EXTENSION -
extension WishlistTableViewController: NSFetchedResultsControllerDelegate {
    
    func initializeFetchedResultsController() {
        
        let request: NSFetchRequest<BookModel> = NSFetchRequest(entityName: "BookModel")
        let sort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = nil
        
        let moc = container.viewContext
        fetchedResultsController = NSFetchedResultsController<BookModel>(
            fetchRequest: request,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError("Unknown section change type")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Unknown object change type")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
