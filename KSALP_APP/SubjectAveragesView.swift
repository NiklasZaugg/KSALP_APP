//
//  SubjectAveragesView.swift
//  KSALP_APP
//
//  Created by Niklas on 24.04.24.
//

import SwiftUI

// Struktur für Fächer und ihre Durchschnitte
struct Subject {
    var name: String
    var averageGrade: Double
}

// View zur Anzeige der Durchschnittsnoten verschiedener Fächer
struct SubjectAveragesView: View {
    let subjects: [Subject] = [
        Subject(name: "Mathematik", averageGrade: 2.3),
        Subject(name: "Englisch", averageGrade: 1.7),
        Subject(name: "Biologie", averageGrade: 1.9)
    ]

    var body: some View {
        NavigationStack {
            List(subjects, id: \.name) { subject in
                NavigationLink(destination: ContentView(subjectName: subject.name)) {
                    HStack {
                        Text(subject.name)
                        Spacer()
                        Text(String(format: "%.2f", subject.averageGrade))
                    }
                }
            }
            .preferredColorScheme(.light) // Erzwingt Light Mode für View
            .navigationTitle("Fächerdurchschnitte")
        }
    }
}


// Preview der neuen View
struct SubjectAveragesView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectAveragesView()
    }
}

