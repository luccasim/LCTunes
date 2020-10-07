//
//  MovieRequest.swift
//  Movie
//
//  Created by owee on 07/10/2020.
//

import Foundation
import CoreData
import Combine

protocol MovieRequestInterface {
    func fetchMovie(Name:String, Context:NSManagedObjectContext)
}

final class MovieRequest : ObservableObject {
    
    let movieAPI = LCItunesAPI(Session: .shared)
    var cancellable : AnyCancellable?

}

extension MovieRequest : MovieRequestInterface {
    
    func fetchMovie(Name: String, Context:NSManagedObjectContext) {
        
        self.cancellable = self.movieFuture(Name: Name)
            .receive(on: RunLoop.main)
            .sink { (comp) in
                switch comp {
                case .finished:
                    print("Fetch Movies finished.")
                case .failure(let err): print(err)
                }
            } receiveValue: { (value) in
                let movies = value.results
                movies.forEach { (rep) in
                    if let url = URLComponents(string: rep.trackViewURL)?.url {
                        let movie = Movie.fetchFirst(Url: url, context: Context)
                        movie.name_ = rep.trackName
                        movie.objectWillChange.send()
                        print("Get \(movie)")
                    }
                }
            }
    }
    
    func movieFuture(Name:String) -> Future<LCItunesAPI.MovieReponse, Error> {
        return Future<LCItunesAPI.MovieReponse, Error> { promise in
            
            self.movieAPI.taskMovie(Term: Name) { (result) in
                do {
                    promise(.success(try result.get()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
