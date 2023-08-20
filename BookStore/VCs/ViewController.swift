//
//  ViewController.swift
//  BookStore
//
//  Created by Rawand Ahmad on 19/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher



class ViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var expandedIndexPath: IndexPath?
    
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        self.setupTableView()
        self.setupRx()
    }
    
    func setupRx() {
        viewModel.books
            .bind(to: tableView.rx.items(cellIdentifier: "booksCell", cellType: BooksTableViewCell.self)) { (row, book, cell) in
                cell.bookTitle.text = book.bookName
                cell.bookDescription.text = book.description
                
                let indexPath = IndexPath(row: row, section: 0)
                cell.isExpanded = indexPath == self.expandedIndexPath
                
                if let constraint = cell.viewHightConstraint {
                   constraint.isActive = cell.isExpanded
                }
                
                if let imageURL = URL(string: book.artwork) {
                    cell.bookImage.kf.setImage(with: imageURL)
                }
                
            }
            .disposed(by: disposeBag)
        
        viewModel.fetchBooks(for: "Daily") // Initial term.
    }
    
    func setupTableView() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
        
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        if text.count == 0 { return }
        viewModel.fetchBooks(for: text)

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if expandedIndexPath == indexPath {
            expandedIndexPath = nil
        } else {
            expandedIndexPath = indexPath
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedIndexPath == indexPath {
            return 200
        }
        return 100
    }
}

