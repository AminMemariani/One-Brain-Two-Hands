import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    
    // Set minimum window size for better gameplay
    self.minSize = NSSize(width: 800, height: 600)
    
    // Set initial window size if needed
    if windowFrame.width < 800 || windowFrame.height < 600 {
      self.setFrame(NSRect(x: windowFrame.origin.x, y: windowFrame.origin.y, width: 800, height: 600), display: true)
    } else {
      self.setFrame(windowFrame, display: true)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
