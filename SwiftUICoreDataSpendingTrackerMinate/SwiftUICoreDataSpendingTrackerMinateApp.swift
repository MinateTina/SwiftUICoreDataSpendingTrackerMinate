//
//  SwiftUICoreDataSpendingTrackerMinateApp.swift
//  SwiftUICoreDataSpendingTrackerMinate
//
//  Created by Tina Tung on 1/31/23.
//

import SwiftUI

@main
struct SwiftUICoreDataSpendingTrackerMinateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainPadDeviceView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
