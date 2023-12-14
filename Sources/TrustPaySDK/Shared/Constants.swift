internal struct Constants {
    #if DEBUG
    static private let apiUrl = "https://aapitest.trustpay.eu"
    #else
    static private let apiUrl = "https://aapi.trustpay.eu"
    #endif
    
    static let authEndpoint = apiUrl + "/api/oauth2/token"
    static let paymentEndpoint = apiUrl + "/api/payments/payment"
}
