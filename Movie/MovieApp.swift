//
//  MovieApp.swift
//  Movie
//
//  Created by owee on 07/10/2020.
//

import SwiftUI

@main
struct MovieApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MovieView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
}
