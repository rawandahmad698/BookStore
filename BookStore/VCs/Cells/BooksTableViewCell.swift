//
//  BooksTableViewCell.swift
//  BookStore
//
//  Created by Rawand Ahmad on 20/08/2023.
//

import UIKit

class BooksTableViewCell: UITableViewCell {
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var viewHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bookImage: UIImageView!
    
    var isExpanded: Bool = false {
        didSet {
            if let constraint = viewHightConstraint {
                constraint.isActive = isExpanded
            }
        }
    }
}
