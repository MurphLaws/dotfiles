import Cocoa
import WebKit
import Network

let args = CommandLine.arguments
guard args.count >= 2, let url = URL(string: args[1]) else {
  FileHandle.standardError.write(Data("uso: qpreview <url> [right|left|full] [puerto-control]\n".utf8))
  exit(2)
}
let side = args.count >= 3 ? args[2] : "right"
// Puerto del canal de control por el que nvim envía órdenes de scroll.
// Por defecto 7778 (el puerto de quarto preview + 1).
let ctrlPort: UInt16 = args.count >= 4 ? (UInt16(args[3]) ?? 7778) : 7778

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

// ── Forward-sync (cursor de nvim → scroll del preview) ───────────────────────
// nvim no puede mapear línea↔píxel como SyncTeX en un PDF; el render es HTML.
// En su lugar, al mover el cursor nvim manda aquí el texto del encabezado más
// cercano por encima del cursor y centramos ESA sección en la página. La
// coincidencia se hace por textContent (lo que de verdad se renderiza), así no
// hace falta reproducir el algoritmo de slug de pandoc/quarto.

// Escapa una cadena para incrustarla como literal '...' de JavaScript.
func jsEscape(_ s: String) -> String {
  var out = ""
  for ch in s.unicodeScalars {
    switch ch {
    case "\\": out += "\\\\"
    case "'":  out += "\\'"
    case "\n": out += "\\n"
    case "\r": out += "\\r"
    case "\u{2028}": out += "\\u2028"
    case "\u{2029}": out += "\\u2029"
    default: out.unicodeScalars.append(ch)
    }
  }
  return out
}

// Centra en el preview el n-ésimo encabezado cuyo texto coincide con `text`.
// `norm` quita un posible número de sección al inicio ("1.2 Título") para que
// la coincidencia funcione aunque esté activo number-sections.
func scrollToHeading(text: String, n: Int) {
  let t = jsEscape(text)
  let js = """
  (function(){
    var t = '\(t)';
    var n = \(n);
    function norm(s){ return s.replace(/\\s+/g,' ').trim().replace(/^[0-9]+(\\.[0-9]+)*\\s+/,''); }
    var hs = [].slice.call(document.querySelectorAll('h1,h2,h3,h4,h5,h6'));
    var m = hs.filter(function(h){ return norm(h.textContent) === norm(t); });
    var el = m.length ? m[Math.min(n - 1, m.length - 1)] : null;
    if (el) { el.scrollIntoView({ block: 'center', behavior: 'smooth' }); }
  })();
  """
  DispatchQueue.main.async {
    webView.evaluateJavaScript(js, completionHandler: nil)
  }
}

// Lee una petición HTTP `GET /scroll?n=..&text=..`, extrae los parámetros
// (URLComponents hace el percent-decoding) y los pasa a scrollToHeading.
func handleRequest(_ path: String) {
  guard let comps = URLComponents(string: "http://localhost" + path),
        comps.path == "/scroll" else { return }
  var text = ""
  var n = 1
  for item in comps.queryItems ?? [] {
    if item.name == "text" { text = item.value ?? "" }
    if item.name == "n" { n = Int(item.value ?? "1") ?? 1 }
  }
  if !text.isEmpty { scrollToHeading(text: text, n: n) }
}

// Servidor TCP mínimo en localhost para el canal de control.
func startControlServer(port: UInt16) {
  guard let nwPort = NWEndpoint.Port(rawValue: port),
        let listener = try? NWListener(using: .tcp, on: nwPort) else {
    FileHandle.standardError.write(Data("qpreview: no pude abrir el puerto de control \(port)\n".utf8))
    return
  }
  listener.newConnectionHandler = { conn in
    conn.start(queue: .global())
    conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, _ in
      if let data = data, let req = String(data: data, encoding: .utf8),
         let firstLine = req.split(separator: "\r\n", maxSplits: 1).first {
        let parts = firstLine.split(separator: " ")
        if parts.count >= 2 { handleRequest(String(parts[1])) }
      }
      let resp = "HTTP/1.1 200 OK\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
      conn.send(content: resp.data(using: .utf8), completion: .contentProcessed({ _ in conn.cancel() }))
    }
  }
  listener.start(queue: .global())
}

startControlServer(port: ctrlPort)

app.activate(ignoringOtherApps: true)
app.run()
