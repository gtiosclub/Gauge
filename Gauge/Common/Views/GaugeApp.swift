//
//  GaugeApp.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct GaugeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var scheduler = Scheduler()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UserResponses.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject var userVM: UserFirebase = UserFirebase()
    @StateObject var postVM: PostFirebase = PostFirebase()
    @State private var navigationPath: NavigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                ContentView()
                    .fullScreenCover(isPresented: $scheduler.shouldInterrupt) {
                        TakeTimeTakesView(scheduler: scheduler)
                    }
            }
        }
//      .modelContainer(for: UserResponses.self)
        .modelContainer(sharedModelContainer)
        .environmentObject(userVM)
        .environmentObject(postVM)
    }
}
