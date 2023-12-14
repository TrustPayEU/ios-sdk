import SwiftUI
import WebKit

internal struct SafariView: UIViewRepresentable {
    let webView = WKWebView()
    @ObservedObject var viewModel: PaymentViewModel
        
    public init(viewModel: PaymentViewModel) {
        self.viewModel = viewModel
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif
        
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        let request = URLRequest(url: viewModel.paymentUrl)
        webView.load(request)
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SafariView
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        #if DEBUG
        public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        }
        #endif
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if(self.parent.viewModel.isLoading) {
                self.parent.viewModel.isLoading = false
            }
        }
        
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {return}
            if url.absoluteString.hasPrefix(self.parent.viewModel.redirectUrl.absoluteString) {
                guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                    decisionHandler(.cancel)
                    return
                }
                
                webView.stopLoading()
                webView.removeFromSuperview()
                decisionHandler(.cancel)
                parent.viewModel.afterRedirectFunction?(RedirectParameters(urlComponents: urlComponents))
                return
            }
            decisionHandler(.allow)
        }
    }
}
