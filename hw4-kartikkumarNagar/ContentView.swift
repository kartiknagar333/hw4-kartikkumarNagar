//
//  ContentView.swift
//  hw4-kartikkumarNagar
//
//  Created by CDMStudent on 5/22/25.
//

import SwiftUI

private enum Lab: String, CaseIterable, Identifiable {
    case fileBrowser   = "Lab 1"
    case tipKitDemo    = "Lab 2"
    case widgetsDemo   = "Lab 3"

    var id: Self { self }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(Lab.allCases) { lab in
                NavigationLink(lab.rawValue, value: lab)
            }
            .navigationTitle("Lab Screens")
                   .navigationDestination(for: Lab.self) { lab in
                       switch lab {
                       case .fileBrowser:  Lab1()
                       case .tipKitDemo:    Lab2()
                       case .widgetsDemo:   Lab3()
                       }
                   }
               }
    }
}

#Preview {
    ContentView()
}
