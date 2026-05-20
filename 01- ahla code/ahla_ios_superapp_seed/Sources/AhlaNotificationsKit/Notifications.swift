import Foundation
import UserNotifications
import UIKit

public final class Notifications: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = Notifications()
    public func register() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { _, _ in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // handle taps
    }
}
