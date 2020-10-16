import SwiftUI
import ImagePlaceholder

struct ContentView: View
{
    var body: some View
    {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach((1 ... 12), id: \.self) { _ in
                    let placeholder = UIImage.placeholder(
                        size: CGSize(
                            width: CGFloat.random(in: 50 ... 150),
                            height: CGFloat.random(in: 50 ... 150)
                        ),
                        theme: .random(),
                        outline: Bool.random()
                    )
                    Image(uiImage: placeholder)
                }
            }

            Spacer(minLength: 20)

            let placeholder = UIImage.placeholder(
                size: CGSize(width: 350, height: 100),
                theme: .gray,
                outline: true,
                font: .preferredFont(forTextStyle: .body),
                text: { _ in "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
            )
            Image(uiImage: placeholder)

        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
