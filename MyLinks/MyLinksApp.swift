//
//  MyLinksApp.swift
//  MyLinks
//
//  Created by Juan Gilsanz Polo on 18/6/24.
//

import SwiftUI

@main
struct MyLinksApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
