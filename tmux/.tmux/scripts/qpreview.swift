// qpreview.swift — visor WebKit nativo para el preview de Quarto.
//
// NO es un navegador: una ventana propia con un WKWebView que carga la URL del
// server `quarto preview`. Se posiciona sola en la mitad indicada de la pantalla
// principal (sin System Events ni AppleScript) y se recarga sola al guardar,
// porque Quarto inyecta su propio livereload en el HTML que sirve.
//
//   qpreview <url> [right|left|full]   (por defecto: right)
//
// Lo compila bajo demanda quarto_split.lua con:
//   swiftc -O qpreview.swift -o ~/.cache/quarto-preview/qpreview

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

// visibleFrame ya excluye la barra de menú y el dock.
let vf = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
let frame: NSRect
switch side {
case "left":
  frame = NSRect(x: vf.minX, y: vf.minY, width: vf.width / 2, height: vf.height)
case "full":
  frame = vf
default:  // right
  frame = NSRect(x: vf.midX, y: vf.minY, width: vf.width / 2, height: vf.height)
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

// Cerrar la ventana (botón rojo o Cmd+W) => terminar el proceso.
final class WinDelegate: NSObject, NSWindowDelegate {
  func windowWillClose(_ notification: Notification) { NSApplication.shared.terminate(nil) }
}
let delegate = WinDelegate()
window.delegate = delegate

app.activate(ignoringOtherApps: true)
app.run()
