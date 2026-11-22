import SwiftUI
import WebKit

struct ContentView: View {
    @State private var isLoading: Bool = true
    @State private var loadProgress: Double = 0.0
    @State private var showSplash: Bool = true
    @State private var loadFailed: Bool = false
    @State private var reloadTrigger: UUID = UUID()

    private let targetUrlString = "https://sites.google.com/view/bolchvoice/champa"
    private let isHtmlMode = false
    private let isExternalBrowserMode = true

    var body: some View {
        ZStack {
            // Primary WKWebView Layer
            if !isExternalBrowserMode {
                VStack(spacing: 0) {
                    if isLoading && loadProgress > 0 && loadProgress < 1 {
                        ProgressView(value: loadProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#79d5ec")))
                            .frame(height: 3)
                    }

                    WebViewContainer(
                        urlString: targetUrlString,
                        isHtmlMode: isHtmlMode,
                        enableJavaScript: true,
                        allowBackSwipe: true,
                        allowZoom: false,
                        googleSitesFix: true,
                        isLoading: $isLoading,
                        progress: $loadProgress,
                        loadFailed: $loadFailed
                    )
                    .id(reloadTrigger)
                    .edgesIgnoringSafeArea(.all)
                }
            }

            // Offline / Error Fallback Screen
            if loadFailed && !isExternalBrowserMode {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 44))
                        .foregroundColor(.gray)
                    Text("ບໍ່ສາມາດເຊື່ອມຕໍ່ອິນເຕີເນັດໄດ້")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("ກະລຸນາກວດສອບການເຊື່ອມຕໍ່ເນັດຂອງທ່ານ ແລ້ວລອງໃໝ່ອີກຄັ້ງ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        loadFailed = false
                        reloadTrigger = UUID()
                    }) {
                        Text("ລອງໂຫຼດໃໝ່")
                            .fontWeight(.bold)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#79d5ec"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#0f172a").edgesIgnoringSafeArea(.all))
            }

            // Custom Splash / Welcome Overlay
            if showSplash {
                ZStack {
                    Color(hex: "#79d5ec")
                        .edgesIgnoringSafeArea(.all)
                    
                    Image("app_bg")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)

                    Color.black.opacity(0.60)
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 16) {
                        Image("AppIconPreview")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 92, height: 92)
                            .cornerRadius(20)
                            .shadow(radius: 10)

                        if !"ພ້ອມ Run ໃນແອັບ Android!".isEmpty {
                            Text("ພ້ອມ Run ໃນແອັບ Android!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }

                        if !"ທ່ານຕ້ອງການ  ຜູ້ຊ່ວຍ ອັດສະລິຍະ ນີ້ເລີຍ".isEmpty {
                            Text("ທ່ານຕ້ອງການ  ຜູ້ຊ່ວຍ ອັດສະລິຍະ ນີ້ເລີຍ")
                                .font(.footnote)
                                .foregroundColor(Color.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                        }

                        Button(action: {
                            if isExternalBrowserMode {
                                if let url = URL(string: targetUrlString) {
                                    UIApplication.shared.open(url)
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showSplash = false
                                }
                            }
                        }) {
                            Text("ເຂົ້າລະບົບ ↗")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .background(Color(hex: "#0284c7"))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(radius: 6)
                        }
                        .padding(.top, 6)

                        if !isExternalBrowserMode {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.top, 8)
                        }
                    }
                    .padding(28)
                }
                .transition(.opacity)
                .onAppear {
                    if !isExternalBrowserMode {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                            withAnimation(.easeOut(duration: 0.35)) {
                                showSplash = false
                            }
                        }
                    }
                }
            }
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let urlString: String
    let isHtmlMode: Bool
    let enableJavaScript: Bool
    let allowBackSwipe: Bool
    let allowZoom: Bool
    let googleSitesFix: Bool
    @Binding var isLoading: Bool
    @Binding var progress: Double
    @Binding var loadFailed: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = enableJavaScript
        config.defaultWebpagePreferences = prefs

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = allowBackSwipe
        webView.scrollView.bounces = true

        if googleSitesFix {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        }

        if !allowZoom {
            let disableZoomScript = "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; document.getElementsByTagName('head')[0].appendChild(meta);"
            let userScript = WKUserScript(source: disableZoomScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(userScript)
        }

        context.coordinator.observe(webView: webView)

        if isHtmlMode {
            if let htmlUrl = Bundle.main.url(forResource: "index", withExtension: "html") {
                webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl.deletingLastPathComponent())
            }
        } else if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer
        private var progressObservation: NSKeyValueObservation?

        init(_ parent: WebViewContainer) {
            self.parent = parent
        }

        func observe(webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] view, _ in
                DispatchQueue.main.async {
                    self?.parent.progress = view.estimatedProgress
                }
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.loadFailed = false
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadFailed = true
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               scheme != "http" && scheme != "https" && scheme != "file" && scheme != "about" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
