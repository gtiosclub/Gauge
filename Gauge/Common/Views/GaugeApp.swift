//
//  GaugeApp.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseMessaging
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        requestPushNotifications(application: application)
        
        return true
    }
    
    func requestPushNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "No Token")")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}

@main
struct GaugeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var scheduler = Scheduler()

    var sharedModelContainer: ModelContainer = {
   //        let schema = Schema([UserResponses.self])
           let schema = Schema([])
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
                        TakeTimeView()
                            .environmentObject(scheduler)
                    }
            }
        }
        .modelContainer(for: UserResponses.self)
        .environmentObject(userVM)
        .environmentObject(postVM)
    }
}
