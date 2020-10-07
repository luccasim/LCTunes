//
//  Movie.swift
//  Movie
//
//  Created by owee on 07/10/2020.
//

import Foundation
import CoreData

extension Movie {
    
    var name : String {
        return self.name_ ?? ""
    }
        
    public override var description: String {
        return "Movie : \(self.url?.absoluteString ?? "")"
    }

    static func fetchFirst(Url:URL, context:NSManagedObjectContext) -> Movie {
        
        let request = NSFetchRequest<Movie>(entityName: "Movie")
        request.predicate = NSPredicate(format: "url = %@", Url as CVarArg)
        request.fetchLimit = 1
        
        if let movie = try? context.fetch(request).first {
            return movie
        }
        
        else {
            let movie = Movie(context: context)
            movie.url = Url
            return movie
        }
    }
    
}
