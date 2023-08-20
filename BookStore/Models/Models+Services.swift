//
//  Models+Services.swift
//  BookStore
//
//  Created by Rawand Ahmad on 20/08/2023.
//
import UIKit
import RxSwift
import RxCocoa

struct SearchResponse: Decodable {
    let resultCount: Int
    let results: [Book]
}

struct Book: Decodable {
    let artwork: String
    let bookName: String
    let description: String
    
    private enum CodingKeys: String, CodingKey {
        case description
        case artwork = "artworkUrl100"
        case bookName = "trackName"
    }
}

class BookService {
    func fetchBooks(for searchTerm: String) -> Observable<[Book]> {
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Observable.just([])
        }
        
        guard let url = URL(string: "https://itunes.apple.com/search?media=ebook&term=\(encodedSearchTerm)") else {
            return Observable.just([])
        }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Accept": "*/*",
            "Accept-Language": "en;q=1.0, ckb-US;q=0.9",
            "User-Agent": "Postman Runtime via BookStore",
            "X-Forwarded-For": "8.8.8.8"
        ]
        
        return URLSession.shared.rx.data(request: request)
            .map { data in
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(SearchResponse.self, from: data)
                    return response.results
                } catch {
                    return []
                }
            }
    }
}


class ViewModel {
    private let bookService = BookService()
    private let disposeBag = DisposeBag()
    
    let books = BehaviorRelay<[Book]>(value: [])
    
    func fetchBooks(for searchTerm: String) {
        bookService.fetchBooks(for: searchTerm)
            .subscribe(onNext: { [weak self] books in
                self?.books.accept(books)
            })
            .disposed(by: disposeBag)
    }
}
