//
//  ContentView.swift
//  Hireica
//
//  Created by HiroakiSaito on 2023/11/27.
//

import SwiftUI

protocol CaptureCameraViewDelegate {
    func passImage(image: UIImage)
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
