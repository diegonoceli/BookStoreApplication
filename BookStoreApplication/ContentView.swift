//
//  ContentView.swift
//  BookStoreApplication
//
//  Created by Diego Noceli on 28/08/23.
//

import SwiftUI
import BookStore

struct ContentView: View {
    
    @State public var books: [Book] = [] // Populate this with your data source
    @State public var showFavoritesOnly = false
    @State public var currentPage = 1
    @State public var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle(isOn: $showFavoritesOnly) {
                    Text("Show Favorites")
                }
                .padding()
                
                List(filteredBooks, id: \.self) { book in
                    if book == books.last {
                        LoadMoreView().onAppear {
                            loadMoreBooks()
                        }
                    }
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookRow(book: book)
                    }
                }
            }
            .onAppear {
                BookStore.shared.fetchBooks(query: "iOS", maxResults: 20, startIndex: 0) { result in
                    switch result {
                    case .success(let fetchedBooks):
                        books = fetchedBooks
                    case .failure(let error):
                        print("Error during fetch books: \(error)")
                    }
                }
            }
            .navigationTitle("Book Store")
        }
    }
    
    public var filteredBooks: [Book] {
        if showFavoritesOnly {
            return books.filter { $0.isFavorite }
        } else {
            return books
        }
    }
    
    public func loadMoreBooks() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        // You can modify this function to load more books from your data source
        BookStore.shared.fetchBooks(query: "iOS", maxResults: 20, startIndex: currentPage * 20) { result in
            switch result {
            case .success(let fetchedBooks):
                books.append(contentsOf: fetchedBooks)
                currentPage += 1
                isLoading = false
            case .failure(let error):
                print("Error during fetch book \(error)")
                isLoading = false
            }
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
    @ObservedObject private var viewModel: BookDetailViewModel
    
    init(book: Book) {
        self.viewModel = BookDetailViewModel(book: book)
        
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let thumbnailURL = viewModel.book.thumbnailURL {
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
                
                Text(viewModel.book.title)
                    .font(.title)
                
                Text("By \(viewModel.book.authors.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(viewModel.book.description)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                if let buyLinkURL = viewModel.book.buyLinkURL {
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
        .onAppear{
            viewModel.isFavorite = UserDefaults.standard.bool(forKey: viewModel.book.title)
        }
        .onDisappear {
            UserDefaults.standard.set(viewModel.isFavorite, forKey: viewModel.book.title)
        }
        .navigationTitle("Book Details")
        .navigationBarItems(
            trailing: Button(action: toggleFavorite) {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? Color.red : Color.primary)
            }
        )
    }
    
    private func toggleFavorite() {
        viewModel.isFavorite.toggle()
        UserDefaults.standard.set(viewModel.isFavorite, forKey: viewModel.book.title)
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
