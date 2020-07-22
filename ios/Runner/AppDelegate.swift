import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var flutter_native_splash = 1
    UIApplication.shared.isStatusBarHidden = false
	FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
	if #available(iOS 10.0, *) {
  // For iOS 10 display notification (sent via APNS)
	UNUserNotificationCenter.current().delegate = self

	let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
	UNUserNotificationCenter.current().requestAuthorization(
    options: authOptions,
    completionHandler: {_, _ in })
	} else {
	let settings: UIUserNotificationSettings =
	UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
	application.registerUserNotificationSettings(settings)
	}

	application.registerForRemoteNotifications()
	
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) { Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
      Messaging.messaging().apnsToken = deviceToken;
  }
}