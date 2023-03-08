//
//  BooksTableViewCell.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/13/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit

class BooksTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "BookCell"
    
    let cellImageView: UIImageView! = {
        let imageView = UIImageView(frame: .init(origin: .zero, size: .init(width: 67.5, height: 90)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 67.5).isActive = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let heartImageView: UIImageView! = {
        let imageView = UIImageView(frame: .init(origin: .zero, size: .init(width: 50, height: 50)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .red
        return imageView
    }()
    
    let titleLabel: UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    let authorLabel: UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    var task: Task<Void, Error>?
    var book: Book?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add views and create layout
        
        let titleAndAuthorStackView = UIStackView(arrangedSubviews: [titleLabel, authorLabel])
        titleAndAuthorStackView.translatesAutoresizingMaskIntoConstraints = false
        titleAndAuthorStackView.axis = .vertical
        titleAndAuthorStackView.distribution = .fill
        titleAndAuthorStackView.spacing = 8

        let outsideStackView = UIStackView(arrangedSubviews: [cellImageView, titleAndAuthorStackView, heartImageView])
        outsideStackView.translatesAutoresizingMaskIntoConstraints = false
        outsideStackView.axis = .horizontal
        outsideStackView.distribution = .fill
        outsideStackView.alignment = .center
        outsideStackView.spacing = 17

        contentView.addSubview(outsideStackView)

        NSLayoutConstraint.activate([
            outsideStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            outsideStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            outsideStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            outsideStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        // reset cell's label and image
        titleLabel.text = ""
        authorLabel?.text = ""
        cellImageView.image = nil
        heartImageView.image = nil
        task?.cancel()
        task = nil
    }
    
    func configure(with book: Book, task: Task<Void, Error>) {
        self.book = book
        titleLabel.text = book.title
        if let authors = book.author {
            authorLabel.text = authors[0].name
        }
        heartImageView.image = book.isFavorite ? UIImage(systemName: "heart.fill") : nil
        self.task = task
    }
    
    
}
