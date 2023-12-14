import SwiftUI

public class PaymentViewModel: ObservableObject {
    var paymentUrl: URL
    var redirectUrl: URL
    var showResult = false
    var afterRedirectFunction: ((RedirectParameters) -> Void)?
    @Published var isLoading: Bool = true
    
    public init(paymentUrl: URL, redirectUrl: URL, showResult: Bool = false, afterRedirectFunction: ( (RedirectParameters) -> Void)? = nil, isLoading: Bool) {
        self.paymentUrl = paymentUrl
        self.redirectUrl = redirectUrl
        self.showResult = showResult
        self.afterRedirectFunction = afterRedirectFunction
    }
}

public struct PaymentView: View {
    @StateObject var viewModel: PaymentViewModel
        
    public var body: some View {
        LoadingView(isShowing: $viewModel.isLoading, content: {
            SafariView(viewModel: viewModel)
        })
    }
}
