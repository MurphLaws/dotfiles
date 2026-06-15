import Cocoa
import WebKit

let args = CommandLine.arguments
guard args.count >= 2, let url = URL(string: args[1]) else {
  FileHandle.standardError.write(Data("uso: qpreview <url> [right|left|full]\n".utf8))
  exit(2)
}
let side = args.count >= 3 ? args[2] : "right"

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let vf = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
let frame: NSRect
switch side {
case "left": frame = NSRect(x: vf.minX, y: vf.minY, width: vf.width / 2, height: vf.height)
case "full": frame = vf
default: frame = NSRect(x: vf.midX, y: vf.minY, width: vf.width / 2, height: vf.height)
}

let window = NSWindow(
  contentRect: frame,
  styleMask: [.titled, .closable, .resizable, .miniaturizable],
  backing: .buffered,
  defer: false)
window.title = "Quarto preview"

let webView = WKWebView(frame: window.contentView!.bounds, configuration: WKWebViewConfiguration())
webView.autoresizingMask = [.width, .height]
window.contentView?.addSubview(webView)
webView.load(URLRequest(url: url))

window.setFrame(frame, display: true)
window.makeKeyAndOrderFront(nil)

final class WinDelegate: NSObject, NSWindowDelegate {
  func windowWillClose(_ notification: Notification) { NSApplication.shared.terminate(nil) }
}
let delegate = WinDelegate()
window.delegate = delegate

app.activate(ignoringOtherApps: true)
app.run()
