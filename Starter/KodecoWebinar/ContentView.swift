import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.kodeco.appleintelligence.demo", category: "main")

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: VisionDemoView()) {
                    Text("Vision framework")
                }
                NavigationLink(destination: CreateMLView()) {
                    Text("CoreML & CreateML")
                }
                NavigationLink(destination: ThirdPartyModelView()) {
                    Text("3rd party models")
                }
            }.navigationTitle("Kodeco Demo")
        }
    }
}

#Preview {
    ContentView()
}
