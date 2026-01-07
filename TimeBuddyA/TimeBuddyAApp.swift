//
//  TimeBuddyAApp.swift
//  TimeBuddyA
//
//  Created by Weerawut on 7/1/2569 BE.
//

import SwiftUI

@main
struct TimeBuddyAApp: App {
    var body: some Scene {
        MenuBarExtra("Time Buddy", systemImage: "person.badge.clock.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
