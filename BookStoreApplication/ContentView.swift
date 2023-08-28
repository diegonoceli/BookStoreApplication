//
//  ContentView.swift
//  BookStoreApplication
//
//  Created by Diego Noceli on 28/08/23.
//

import SwiftUI
import BookStore

struct ContentView: View {
    
    @State private var books: [Book] = [] // Populate this with your data source
    @State private var showFavoritesOnly = false
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: toggleFavoritesFilter) {
                    Text(showFavoritesOnly ? "Show All" : "Show Favorites")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                List(filteredBooks, id: \.self) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookRow(book: book)
                    }
                }
            }
            .navigationTitle("Book Store")
        }
        .onAppear {
            BookStore.shared.fetchBooks(query: "iOS", maxResults: 20, startIndex: 0) { result in
                switch result {
                case .success(let fetchedBooks):
                    print("Fetched Books: \(fetchedBooks)")
                    books = fetchedBooks
                case .failure(let error):
                    print("Error during fetch books: \(error)")
                }
            }
        }
    }
    
    private var filteredBooks: [Book] {
        if showFavoritesOnly {
            return books.filter { $0.isFavorite }
        } else {
            return books
        }
    }
    
    private func toggleFavoritesFilter() {
        showFavoritesOnly.toggle()
    }

}

struct BookRow: View {
    let book: Book
    var body: some View {
        HStack {
            AsyncImage(url: book.thumbnailURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 120)
                    .cornerRadius(8)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 120)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.headline)
                
                Text(book.authors.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

struct BookDetailView: View {
    @State private var isFavorite: Bool
    let book: Book
    
    init(book: Book) {
        self._isFavorite = State(initialValue: book.isFavorite)
        self.book = book
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let thumbnailURL = book.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                }
                
                Text(book.title)
                    .font(.title)
                
                Text("By \(book.authors.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(book.description)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                if let buyLinkURL = book.buyLinkURL {
                    Button(action: {
                        openURL(buyLinkURL)
                    }) {
                        Text("Buy Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onDisappear {
            UserDefaults.standard.set(isFavorite, forKey: book.title)
        }
        .navigationTitle("Book Details")
        .navigationBarItems(
            trailing: Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? Color.red : Color.primary)
            }
        )
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        UserDefaults.standard.set(isFavorite, forKey: book.title)
    }
}

private func openURL(_ url: URL) {
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
