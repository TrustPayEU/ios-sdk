import Foundation

public struct RedirectParameters {
    public var url: String
    public var paymentRequestId: Int64?
    public var reference: String?
    
    public init(url: String, paymentRequestId: Int64? = nil, reference: String? = nil) {
        self.url = url
        self.paymentRequestId = paymentRequestId
        self.reference = reference
    }
    
    init(urlComponents: URLComponents) {
        var paymentRequestId: Int64
        let paymentRequestIdString = urlComponents.queryItems?.first(where: { $0.name == "PaymentRequestId"})?.value
        if paymentRequestIdString == nil {
            paymentRequestId = 0
        } else {
            paymentRequestId = Int64(paymentRequestIdString!) ?? 0
        }
        self.url = urlComponents.url?.absoluteString ?? "";
        self.paymentRequestId = paymentRequestId;
        self.reference = urlComponents.queryItems?.first(where: { $0.name == "Reference"})?.value ?? "NOTPROVIDED"
        
    }
}
