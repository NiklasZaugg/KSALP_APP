//
//  KSALP_APPApp.swift
//  KSALP_APP
//
//  Created by Niklas on 24.02.24.
//

import SwiftUI
import RealmSwift

@main
struct YourApp: SwiftUI.App {
    init() {
        configureRealm()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                }
            })
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm()
        } catch let error as NSError {
            fatalError("Fehler beim Initialisieren von Realm: \(error.localizedDescription)")
        }
    }
}
