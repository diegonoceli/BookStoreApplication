//
//  BookDetailVie.swift
//  BookStoreApplication
//
//  Created by Diego Noceli on 30/08/23.
//

import Foundation
import BookStore
class BookDetailViewModel: ObservableObject {
    @Published var book: Book
    @Published var isFavorite: Bool
    
    init(book: Book) {
        self.book = book
        self.isFavorite = UserDefaults.standard.bool(forKey: book.title)
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        UserDefaults.standard.set(isFavorite, forKey: book.title)
    }
}
