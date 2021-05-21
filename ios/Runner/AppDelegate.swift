import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UIApplication.shared.isStatusBarHidden = false
    GeneratedPluginRegistrant.register(with: self)
	UNUserNotificationCenter.current().delegate = self
	let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
	UNUserNotificationCenter.current().requestAuthorization(
    options: authOptions,
    completionHandler: {_, _ in })
    
	application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) { Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
      Messaging.messaging().apnsToken = deviceToken;
  }
}


