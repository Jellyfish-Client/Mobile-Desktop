import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    // Persist size and position across launches via AppKit.
    self.setFrameAutosaveName("JellyfishMainWindow")
    // Match the Flutter Scaffold background so cold-start has no white flash.
    self.backgroundColor = .black

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
