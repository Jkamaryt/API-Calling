//
//  ContentView.swift
//  API Calling
//
//  Created by Jack Kamaryt on 2/27/23.
//
// API - https://www.fishwatch.gov/api/species
//struct Species_Names: Codable {
//var Species_Name: [String]
//}

import WebKit
import SwiftUI

struct ContentView: View {
    @State private var species = [Species]()
    @State private var showingAlert = false
    var body: some View {
        NavigationView {
            List(species) { fish in
                NavigationLink {
                    VStack {
                        Text(fish.name)
                            .font(.title).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Biology:")
                            .position(x:32, y:0)
                        HTMLStringView(htmlContent: fish.biology)
                            .position(x:190, y:-55)
                        Text("Physical Description:")
                            .position(x:82,y:-95)
                        HTMLStringView(htmlContent: fish.physicalDescription)
                            .position(x:190, y:-140)
                        HStack {
                            Text("More Information:")
                                .position(x:70,y:-180)
                            Link("\(fish.name)", destination: URL(string:  "https://www.fishwatch.gov\(fish.path)")!)
                                .position(x:30,y:-180)
                        }
                    }
                } label: {
                    Text(fish.name)
                }
                
            }
            .navigationTitle("Fishies")
        }
        .task { await getSpecies()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"),
                  message: Text("There was a problem loading the Fishies"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func getSpecies() async {
        let query = "https://www.fishwatch.gov/api/species"
        if let url = URL(string: query) {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode([Species].self, from: data) {
                    species = decodedResponse
                    return
                }
            }
        }
        showingAlert = true
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Species: Identifiable, Codable {
    var id = UUID()
    var name: String
    var biology: String
    var physicalDescription: String
    var path: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Species Name"
        case biology = "Biology"
        case physicalDescription = "Physical Description"
        case path = "Path"
    }
}

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
