import SwiftUI

// Inspired from Fruta Apple Developer app
struct ImageActionButton: View {
    var label: LocalizedStringKey
    var systemImage: String
    var action: () -> Void
    
    init(label: LocalizedStringKey, systemImage: String, _ action: @escaping () -> Void) {
        self.label = label
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .font(Font.title.bold())
                    .aspectRatio(contentMode: .fit)
                    .padding(2)
                    .frame(width: 44, height: 44)
                    .padding()
                    .foregroundStyle(.primary)
                
                Image(systemName: systemImage)
                    .resizable()
                    .font(Font.title.bold())
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
                    .padding()
                    .contentShape(Rectangle())
                    .foregroundStyle(.thickMaterial)
            }
        }
        .buttonStyle(.squishable(fadeOnPress: false))
        .accessibility(label: Text(label))
    }
}

#Preview {
    ImageActionButton(label: "Close", systemImage: "xmark") { }
        .previewLayout(.sizeThatFits)
}
