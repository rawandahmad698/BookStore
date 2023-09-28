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
    func updateSearchResults(for searchController: UISearchController) {}
    
    
    // Table View
    @IBOutlet weak var tableView: UITableView!
    var expandedIndexPath: IndexPath?
    
    // Models
    private let viewModel = ViewModel()
    private let disposeBag = DisposeBag()
    
    // Search
    let search = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        self.setupSearch()
        self.setupTableView()
    }
    
    func setupSearch() {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        let searchInput = search.searchBar.searchTextField.rx
            .controlEvent(.editingDidEndOnExit)
            .map { self.search.searchBar.text ?? "" }
            .filter { !$0.isEmpty }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        let searchComplete = PublishSubject<Void>()

        let textSearch = searchInput.flatMap { text in
            activityIndicator.startAnimating()
            self.search.isActive = false
            return self.viewModel.fetchBooks(for: text)
                .observe(on: MainScheduler.instance) // Switch to the main thread
                .do(onCompleted: {
                    searchComplete.onNext(())
                })
                .catch { [weak self] error in
                    switch error as? ApiError {
                    case .bookNotFound:
                        self?.showAlert(title: "No books found for \(text)")
                    case .serverFailure:
                        self?.showAlert(title: "Server is experiencing issues")
                    default:
                        self?.showAlert(title: "An unknown error occured")
                    }
                    searchComplete.onNext(())
                    return .empty()
                }
        }
        
        textSearch
            .bind(to: tableView.rx.items(cellIdentifier: "booksCell", cellType: BooksTableViewCell.self)) { (row, book, cell) in
                cell.bookTitle.text = book.bookName
                cell.bookDescription.text = book.description
                cell.bookPrice.text = book.formattedPrice
                
                let indexPath = IndexPath(row: row, section: 0)
                cell.isExpanded = indexPath == self.expandedIndexPath
                
                if let constraint = cell.viewHightConstraint {
                   constraint.isActive = cell.isExpanded
                }
                
                if let imageURL = URL(string: book.artwork) {
                    cell.bookImage.kf.setImage(with: imageURL)
                }
                activityIndicator.stopAnimating()
            }
            .disposed(by: disposeBag)
        
        searchComplete
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                activityIndicator.stopAnimating()
                self?.search.searchBar.searchTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
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
    
    func showAlert(title: String) {
        let alertController = UIAlertController(
            title: title,
            message: "",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }

}

