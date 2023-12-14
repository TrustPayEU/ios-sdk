import SwiftUI

internal struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content
    public var body: some View {
        GeometryReader {
            geometry in
            ZStack(alignment: .center, content: {
                self.content()
                    .disabled(self.isShowing)
                VStack {
                    Text("Loading...")
                     ActivityIndicatorView(isAnimating: .constant(true), style: .large)
                }.disabled(!self.isShowing)
                    .frame(width: geometry.size.width / 2, height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
            })
        }
    }
}
