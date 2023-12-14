import Foundation

public class CardRequest: BaseRequest {
    public var merchantIdentification: MerchantIdentification 
    public var paymentInformation: PaymentInformation
    public var callbackUrls: CallbackUrls?
    public let paymentMethod = "Card"

    public init(merchantIdentification: MerchantIdentification, paymentInformation: PaymentInformation, cardTransaction: CardTransaction,
                callbackUrls: CallbackUrls? = nil) {
        self.merchantIdentification = merchantIdentification
        self.paymentInformation = paymentInformation
        self.callbackUrls = callbackUrls
        self.paymentInformation.cardTransaction = cardTransaction
    }

    
    enum CodingKeys: String, CodingKey {
        case paymentMethod, merchantIdentification, callbackUrls, paymentInformation, cardTransaction
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentMethod, forKey: .paymentMethod)
        try container.encode(merchantIdentification, forKey: .merchantIdentification)
        try container.encodeIfPresent(callbackUrls, forKey: .callbackUrls)
        try container.encode(paymentInformation, forKey: .paymentInformation)
    }
}

public class CardResponse: BaseResponse { }
