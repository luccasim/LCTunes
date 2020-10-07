//
//  MovieView.swift
//  Movie
//
//  Created by owee on 07/10/2020.
//

import Foundation
import SwiftUI
import CoreData

struct MovieView : View {
    
    @Environment(\.managedObjectContext) var context : NSManagedObjectContext
    @ObservedObject var movieRequest = MovieRequest()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Movie.name_, ascending: true)],
        animation: .default)
    var movies: FetchedResults<Movie>
    
    @State private var searchText : String = ""
    
    var body: some View {
        SearchBarView(text: $searchText)
        List {
            ForEach(self.movies, id:\.url) { movie in
                Text("\(movie.name)")
            }
        }.onAppear() {
            self.movieRequest.fetchMovie(Name: "Avengers", Context: context)
        }
    }
    
}


struct MovieView_Previews: PreviewProvider {
    
    static var previews: some View {
        MovieView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
