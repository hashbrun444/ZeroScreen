//
//  ZeroScreenApp.swift
//  ZeroScreen
//
//  Created by Cristian Matache on 12/16/24.
//

import SwiftUI
import SwiftData

@main
struct ZeroScreenApp: App {
    @StateObject var appData = AppData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .onAppear {
                    appData.debugEnabled = false // turn this on/off as needed
                    appData.debugPrintState()
                }
        }
    }
}
