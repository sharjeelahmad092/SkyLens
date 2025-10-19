//
//  ContentView.swift
//  SkyLens
//
//  Created by Sharjeel Ahmad on 2025-10-18.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                // Main app content
                TabView {
                    WeatherView()
                        .tabItem {
                            Label("Weather", systemImage: "cloud.sun.fill")
                        }

                    NavigationStack {
                        ContactView()
                    }
                    .tabItem {
                        Label("Contact", systemImage: "envelope.fill")
                    }
                }
            } else {
                // Simple splash screen with just the app icon and name
                ZStack {
                    // Full screen background with accent color
                    Color("AccentColor")
                        .ignoresSafeArea()

                    // Main splash content - just icon and name
                    VStack(spacing: 20) {
                        Image("LaunchIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 30))

                        Text("SkyLens")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            // Simple delay to show splash screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isActive = true
            }
        }
    }
}

#Preview {
    ContentView()
}
