//
//  GaugeApp.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import FirebaseMessaging
extension Notification.Name {
    static let triggerInterruptFromFCM = Notification.Name("triggerInterruptFromFCM")
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        requestNotificationPermission(application: application)
        
        return true
    }
    
    private func requestNotificationPermission(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("User denied notification permissions: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        handleNotificationPayload(userInfo)
        completionHandler(.newData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        print("FCM Token: \(fcmToken ?? "No Token")")
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let interrupt = userInfo["interrupt"] as? String, interrupt == "true" {
            NotificationCenter.default.post(name: .triggerInterruptFromFCM, object: nil)
        }
        
        completionHandler()
    }
    
    private func handleNotificationPayload(_ userInfo: [AnyHashable: Any]) {
        print("Received notification payload: \(userInfo)")
        
        if let customType = userInfo["customType"] as? String, customType == "interrupt" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .triggerInterruptFromFCM, object: nil)
            }
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
}
