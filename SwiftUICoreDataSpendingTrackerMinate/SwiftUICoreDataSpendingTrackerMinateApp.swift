//
//  SwiftUICoreDataSpendingTrackerMinateApp.swift
//  SwiftUICoreDataSpendingTrackerMinate
//
//  Created by Tina T on 1/31/23.
//

import SwiftUI

@main
struct SwiftUICoreDataSpendingTrackerMinateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
