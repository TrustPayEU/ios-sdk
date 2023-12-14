<h1 align="center">TrustPay iOS SDK</h1>

<p align="center">
  <a href="#about">About</a> &#xa0; | &#xa0; 
  <a href="#features">Features</a> &#xa0; | &#xa0;
  <a href="#requirements">Requirements</a> &#xa0; | &#xa0;
  <a href="#usage">Usage</a> &#xa0; | &#xa0;
  <a href="#license">License</a> &#xa0; | &#xa0;
</p>


## About ##

The TrustPay iOS SDK is a beta version designed to integrate basic payment processing functionalities into iOS applications. Developed in Kotlin, this SDK supports crucial payment methods such as card transactions and wire transfers, offering a secure and straightforward solution for iOS developers.

## Features ##

- Wire Transfers
- Card(Purchase)

## Requirements ##

- iOS 14.0 or later
- Swift 5.0 or later
- Xcode 11 or later

## Installation ##

To integrate the SDK into your Xcode project, you need to open:
File > Add Package Dependency and insert this repository url

## Usage ##

Import the SDK in your Swift file:
```
import TrustPaySDK
```
Setup TokenProvider:
```
var tokenProvider = TokenProvider(projectId: {YourProjectId}, secret: {YourSecretKey})
```
Setup Wire Request: 
```
val wireRequest = WireRequest(merchantIdentification: MerchantIdentification(projectId: {YourProjectId}),
                            paymentInformation: PaymentInformation(
                                amount: AmountWithCurrency(amount: {amount}, currency: {currency}),
                                references: References(merchantRefenence: {reference})),
                            callbackUrls: nil)
```

Setup CardRequest:
```
val request = CardRequest(merchantIdentification: MerchantIdentification(projectId: "4107642030"),
                            paymentInformation: PaymentInformation(
                                amount: AmountWithCurrency(amount: amountDecimal, currency: currency),
                                references: References(merchantRefenence: reference),
                                localization: "SK", country: "SK"), cardTransaction: CardTransaction(paymentType: CardPaymentType.purchase),
                            callbackUrls: nil)
```

#### Get response and show gateway ###
```
// SetupView
request.createPaymentRequest(tokenProvider: tokenProvider, completion: saveResponseAndSwitchCurrentPage)
func saveResponseAndSwitchCurrentPage(result: Result<PaymentResponse, Error>) {
    switch(result) {
    case .success(let apiResponse):
        showGateway(apiResponse)
    case .failure(let error as TpApiError):
        // handle api error
    case .failure(let error):
        // handle general error
    }
}

func showGateway(response: PaymentResponse, completion: ((RedirectParameters) -> Void)) {
    // show navigation link and set the response as body
    response.getGatewayView(redirectUrl: "https://examle.com/payment", closeFunction: setParamsAndShowResult)
}

func setParamsAndShowResult(result: RedirectParameters) {
    // switch to result page
}
```
Customization

As this is a beta version, customization options are limited. Future updates will include more customization features.

## License ##

This project is under license from MIT. For more details, see the [LICENSE](LICENSE.md) file.

&#xa0;

<a href="#top">Back to top</a>
