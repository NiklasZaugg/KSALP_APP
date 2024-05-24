//
//  ScheduleView.swift
//  KSALP_APP
//
//  Created by Niklas on 24.05.24.
//

import SwiftUI

// Hauptansicht der Anwendung
struct ScheduleView: View {
    let classes = [
            "U23a", "U23b", "U23c", "U23d", "U23e", "U23f", "U23g", "U23h", "U23i", "U23k", "U23l", "U23m", "U23n",
            "U22a", "U22b", "U22c", "U22d", "U22e", "U22f", "U22g", "U22h", "U22i", "U22k", "U22l", "U22m", "U22n",
            "G23a", "G23b", "G23c", "G23d", "G23e", "G23f", "G23g", "G23h", "G23i", "G23k", "G23l", "G23m", "G23n",
            "T23a", "T23b",
            "G22a", "G22b", "G22c", "G22d", "G22e", "G22f", "G22g", "G22h", "G22i", "G22k", "G22l", "G22m",
            "T22a","T22b",
            "G21a", "G21b", "G21c", "G21d", "G21e", "G21f", "G21g", "G21h", "G21i", "G21k", "G21l", "G21m", "G21n",
            "T21a","T21b",
            "G20a", "G20b", "G20c", "G20d", "G20e", "G20f", "G20g", "G20h", "G20i", "G20k", "G20l",
            "T20a","T20b",
            "T19a","T19b"
        ]
        
    
    @State private var selectedClass: String? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(classes, id: \.self) { className in
                            Button(action: {
                                selectedClass = className
                            }) {
                                Text(className)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
                if let selectedClass = selectedClass {
                    TimetableView(className: selectedClass)
                }
            }
            .navigationTitle("Stundenplan")
        }
    }
}

// Detailansicht für den Stundenplan einer Klasse
struct TimetableView: View {
    let className: String
    
    var body: some View {
        VStack {
            Text("Stundenplan für \(className)")
                .font(.largeTitle)
                .padding()
            //Stundenplan hinzufügen
            Text("Montag: Mathe, Deutsch, Sport")
            Text("Dienstag: Englisch, Kunst, Biologie")
            Text("Mittwoch: Geschichte, Musik, Physik")
            Spacer()
        }
        .padding()
    }
}

// Preview für die Hauptansicht
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}

