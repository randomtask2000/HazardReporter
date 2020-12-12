//
//  HazardReporterApp.swift
//  Shared
//
//  Created by Emilio Nicoli on 12/12/20.
//

import SwiftUI

@main
struct HazardReporterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
