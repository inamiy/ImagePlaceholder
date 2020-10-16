import AppKit
import SwiftUI
import ImagePlaceholder

struct ContentView: View
{
    var body: some View
    {
        // NOTE: LazyVGrid is not available in macOS 10.x
        ScrollView {
            VStack(spacing: 20) {
                ForEach((1 ... 4), id: \.self) { _ in
                    HStack(spacing: 20) {
                        ForEach((1 ... 3), id: \.self) { _ in
                            image()
                        }
                    }
                }
            }

            Spacer(minLength: 20)

            lorem()
        }
        .background(Color.white)
    }

    private func image() -> some View
    {
        let placeholder = NSImage.placeholder(
            size: CGSize(
                width: CGFloat.random(in: 50 ... 150),
                height: CGFloat.random(in: 50 ... 150)
            ),
            theme: .random(),
            outline: Bool.random()
        )
        return Image(nsImage: placeholder)
    }

    private func lorem() -> some View
    {
        let placeholder = NSImage.placeholder(
            size: CGSize(width: 350, height: 100),
            theme: .random(),
            outline: .random(),
            font: .systemFont(ofSize: 14),
            text: { _ in "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
        )
        return Image(nsImage: placeholder)
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
