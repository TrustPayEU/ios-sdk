import Foundation

public class BaseRequest: Encodable {
}

extension BaseRequest {
    // TODO
    /*@available(iOS 15.0, *)
    public func createPaymentRequestAsync(tokenProvider: TokenProvider) async -> Result<String, Error> {
        let token: String
        switch await tokenProvider.getTokenAsync() {
        case .success(let tokenObject):
            token = tokenObject.accessToken!
        case .failure(let error):
            return .failure(error)
        }
        do {
            let response: Result<WireResponse, Error> = try await HttpHelper.shared.performRequestAsync(url: Constants.paymentEndpoint,
                                                                            headers: ["Authorization": "Bearer \(token)"],
                                                                            data: JsonHelper.shared.toJson(self), mediaType: "application/json")
            switch response {
            case .success(let wireResponse):
                if wireResponse.gatewayUrl == nil {
                    return .failure(wireResponse.toError())
                } else {
                    return .success(wireResponse.gatewayUrl!)
                }
            case .failure(let error):
                return .failure(error)
            }
        } catch let error {
            return .failure(error)
        }
    }*/
    
    public func createPaymentRequest(tokenProvider: TokenProvider, completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        tokenProvider.getToken(completion: {
            (result) in
            switch result {
                case .success(let tokenResp):
                self.createRequest(token: tokenResp.accessToken!, completion: {
                    (response) in
                    switch response {
                    case .success(let wireResponse):
                        completion(.success(wireResponse))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
                case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func createRequest(token: String, completion: @escaping (Result<WireResponse, Error>) -> Void) {
        HttpHelper.shared.performRequest(url: Constants.paymentEndpoint, headers: ["Authorization": "Bearer \(token)"], data: JsonHelper.shared.toJson(self), mediaType: "application/json", completion: {
            (result: Result<WireResponse, Error>) in
            switch result {
                case .success(let paymentResponse):
                    completion(.success(paymentResponse))
                    return
                case .failure(let error):
                    completion(.failure(error))
                    return
            }
        })
    }
}

public struct MerchantIdentification: Encodable {
    public var projectId: String?
       
    public init(projectId: String) {
        self.projectId = projectId
    }    
}

public struct PaymentInformation: Encodable {
    var amount: AmountWithCurrency
    var references: References
    var localization: String
    var debtor: PartyIdentification?
    var debtorAccount: FinancialAccount?
    var debtorAgent: FinancialInstitution?
    var dueDate: Date?
    var remittanceInformation: String?
    var sepaDirectDebitInformation: SddInformation?
    var country: String?
    var cardTransaction: CardTransaction?
    var isRedirect: Bool = true
    
    public init(amount: AmountWithCurrency, references: References, localization: String, debtor: PartyIdentification? = nil, debtorAccount: FinancialAccount? = nil, debtorAgent: FinancialInstitution? = nil, dueDate: Date? = nil, remittanceInformation: String? = nil, sepaDirectDebitInformation: SddInformation? = nil, country: String? = nil, cardTransaction: CardTransaction? = nil) {
        self.amount = amount
        self.references = references
        self.localization = localization
        self.debtor = debtor
        self.debtorAccount = debtorAccount
        self.debtorAgent = debtorAgent
        self.dueDate = dueDate
        self.remittanceInformation = remittanceInformation
        self.sepaDirectDebitInformation = sepaDirectDebitInformation
        self.country = country
        self.cardTransaction = cardTransaction
    }
}

public struct AmountWithCurrency: Encodable {
    var amount: String
    var currency: String

    public init(amount: Decimal, currency: String) {
        self.amount = AmountWithCurrency.formatDecimal(amount: amount)
        self.currency = currency
    }

    public static func formatDecimal(amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter.string(from: amount as NSNumber) ?? ""
    }
}

public struct References: Encodable {
    var merchantReference: String
    
    public init(merchantRefenence: String) {
        self.merchantReference = merchantRefenence
    }
}

public struct PartyIdentification: Encodable {
    public var name: String
    public var id: String
}

public struct FinancialAccount: Encodable {
    public var accountNumber: String
    public var iban: String
}

public struct FinancialInstitution: Encodable {
    public var institutionName: String
    public var institutionCode: String
}

public struct SddInformation: Encodable {
    public var information1: String
    public var information2: String
}

public struct CardTransaction: Encodable {
    public var paymentType: CardPaymentType
    public var transactionId: String?
    
    public init(paymentType: CardPaymentType, transactionId: String? = nil) {
        self.paymentType = paymentType
        self.transactionId = transactionId
    }
    
    enum CodingKeys: String, CodingKey {
        case paymentType = "PaymentType", transactionId = "TransactionId"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentType, forKey: .paymentType)
        try container.encodeIfPresent(transactionId, forKey: .transactionId)
    }
}

public struct CallbackUrls: Encodable {
    public var success: String?
    public var cancel: String?
    public var error: String?
    public var notification: String?
}

public enum CardPaymentType: String, Encodable {
    case purchase = "Purchase", preauthorization = "Preauthorization"
}
