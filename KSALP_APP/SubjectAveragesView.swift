//
//  SubjectAveragesView.swift
//  KSALP_APP
//
//  Created by Niklas on 24.04.24.
//

import SwiftUI

struct SubjectAveragesView: View {
    @ObservedObject var semester: Semester
    
    var overallAverage: Double { // Berechnet den gewichteten Durchschnitt aller Fächer in einem Semester
        let weightedAverages = semester.subjects.map { $0.averageGrade }
        let sum = weightedAverages.reduce(0, +)
        return !weightedAverages.isEmpty ? sum / Double(weightedAverages.count) : 0
    }

    var body: some View {
        NavigationStack {
            List($semester.subjects, id: \.id) { $subject in// Die Verwendung von .id gewährleistet eine eindeutige Identifikation der Listenelemente.
                NavigationLink(destination: ContentView(subject: $subject)) {
                    HStack {
                        Text(subject.name)// Anzeige des Namens des Faches
                        Spacer()
                        Text(String(format: "%.2f", subject.averageGrade)) // Anzeige des Durchschnitts des Faches auf zwei Dezimalstellen
                    }
                }
            }
            .navigationTitle("Fächerdurchschnitte")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fach hinzufügen") {
                        let newSubject = Subject(name: "Neues Fach")
                        semester.subjects.append(newSubject)// Fügt das neue Fach der Liste hinzu.
                    }
                }
            }
            .preferredColorScheme(.light)
            Text("Gesamtdurchschnitt aller Fächer: \(String(format: "%.2f", overallAverage))")//Anzeige Gesamtdurchschnitt
                .padding()
        }
    }
}





