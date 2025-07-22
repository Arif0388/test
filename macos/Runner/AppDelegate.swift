import Cocoa
import FlutterMacOS
import app_links

@main
class AppDelegate: FlutterAppDelegate {
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // Method to handle universal links
    public override func application(_ application: NSApplication,
                                     continue userActivity: NSUserActivity,
                                     restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        
        guard let url = AppLinks.shared.getUniversalLink(userActivity) else {
            return false
        }
        
        // Handle the incoming link and communicate it to Flutter
        AppLinks.shared.handleLink(link: url.absoluteString)
        
        // Return true to indicate the app has handled the link and will not pass it on
        return true
    }
}
