import SwiftUI

struct MLLearnView: View {
    @EnvironmentObject var appModel: AppModel
    
    @State private var showingInfoSheet = false
    
    var body: some View {
        ASLLearnView() {
            showingInfoSheet = true
        }
        .onAppear {
            if UserDefaults.standard.object(forKey: "show_info_view") == nil {
                UserDefaults.standard.setValue(true, forKey: "show_info_view")
            }
            
            if UserDefaults.standard.object(forKey: "show_info_view") as? Bool ?? false {
                showingInfoSheet = true
            }
        }
        .sheet(isPresented: $showingInfoSheet) {
            InfoView()
        }
        .environmentObject(appModel)
    }
}
