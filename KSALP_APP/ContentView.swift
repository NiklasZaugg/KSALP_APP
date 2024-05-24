//
//  ContentView.swift
//  KSALP_APP
//
//  Created by Niklas on 23.05.24.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SemesterView()
                .tabItem {
                    Label("Semester", systemImage: "list.bullet")
                }
            
            PointCalculatorView()
                .tabItem {
                    Label("PunktRechner", systemImage: "list.bullet")
                }
            ScheduleView()
                .tabItem{
                    Label("Stundenplan", systemImage: "list.bullet")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

