import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            gradient
            
            VStack(spacing: 15) {
                Text("Welcome to LearnASL")
                    .font(.largeTitle.weight(.semibold))
                    .shadow(radius: 2)
                
                descriptionText
                    .font(.title3.weight(.medium))
                    .shadow(radius: 1)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                infoText1
                    .shadow(radius: 1)
                
                infoText2
                    .shadow(radius: 1)
                
                infoText3
                    .shadow(radius: 1)
                    .padding(.bottom, 16)
                
                Button("Continue") {
                    dismiss()
                    UserDefaults.standard.setValue(false, forKey: "show_info_view")
                }
                .buttonStyle(.prominent(squishable: true))
            }
            .padding(.horizontal, 32)
        }
    }
    
    private var descriptionText: Text {
        Text("LearnASL uses CoreML ") + Text(Image(systemName: "square.stack.3d.up.fill")) + Text(" with other ") + Text(Image(systemName: "applelogo")) + Text(" frameworks to help learn the American Sign Language alphabet.")
    }
    
    private var infoText1: Text {
        Text("Sign language is the most accessible language for people who are deaf and hard of hearing. LearnASL will help you learn the ASL alphabet so you can start to fingerspell words like your name!")
    }
    
    private var infoText2: Text {
        Text("However, it’s important to keep in mind that ASL is as complex, detailed, and intricate as any other spoken language. Yet, there is a lack of learning resources compared to other languages, especially those that are interactive and engaging.")
    }
    
    private var infoText3: Text {
        Text("I’m hoping LearnASL is a good first step towards putting accessibility at the forefront of considerations people make when creating and learning new things!")
    }
    
    // Gradient from MusicAlbums Apple Developer app
    private var gradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: (130.0 / 255.0), green: (100.0 / 255.0), blue: (175.0 / 255.0)),
                Color(red: (130.0 / 255.0), green: (140.0 / 255.0), blue: (190 / 255.0)),
                Color(red: (131.0 / 255.0), green: (170.0 / 255.0), blue: (210 / 255.0))
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .flipsForRightToLeftLayoutDirection(false)
        .ignoresSafeArea()
    }
}
