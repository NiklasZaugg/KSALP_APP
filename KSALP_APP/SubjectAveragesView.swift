//
//  SubjectAveragesView.swift
//  KSALP_APP
//
//  Created by Niklas on 24.04.24.
//

import SwiftUI

struct SubjectAveragesView: View {
    @ObservedObject var semester: Semester
    @State private var showingAddSubjectSheet = false // State für das Sheet
    @State private var newSubjectName = "" // State für den Namen des neuen Fachs
    @State private var isMaturarelevant = false // State für den Maturarelevanz-Toggle
    
    var overallAverage: Double { // Berechnet den gewichteten Durchschnitt aller Fächer mit Noten in einem Semester
         let subjectsWithGrades = semester.subjects.filter { !$0.grades.isEmpty }
         let weightedAverages = subjectsWithGrades.map { $0.averageGrade }
         let sum = weightedAverages.reduce(0, +)
         return !weightedAverages.isEmpty ? sum / Double(weightedAverages.count) : 0
     }

     var overallAverageText: String { // Gibt den Gesamtdurchschnitt als Text zurück
         return overallAverage == 0 && semester.subjects.allSatisfy { $0.grades.isEmpty } ? "-" : String(format: "%.2f", overallAverage)
     }
    
    // Berechnung für Maturadurchschnitt
    var maturaAverage: Double {
        let maturaSubjects = semester.subjects.filter { $0.isMaturarelevant && !$0.grades.isEmpty }
        let weightedAverages = maturaSubjects.map { $0.averageGrade }
        let sum = weightedAverages.reduce(0, +)
        return !weightedAverages.isEmpty ? sum / Double(weightedAverages.count) : 0
    }

    //Textdarstellung für Maturadurchschnitt
    var maturaAverageText: String {
        return maturaAverage == 0 ? "-" : String(format: "%.2f", maturaAverage)
    }





    var body: some View {
        NavigationStack {
            List($semester.subjects, id: \.id) { $subject in // Die Verwendung von .id gewährleistet eine eindeutige Identifikation der Listenelemente.
                NavigationLink(destination: ContentView(subject: $subject)) {
                    HStack {
                        Text(subject.name) // Anzeige des Namens des Faches
                            .lineLimit(1) // Begrenzung auf eine Zeile
                            .truncationMode(.tail) // Text abschneiden mit "..."
                            .frame(maxWidth: .infinity, alignment: .leading) // Maximale Breite auf die verfügbare Breite begrenzen
                        Spacer()
                        Text(subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade)) // Anzeige des Durchschnitts des Faches auf zwei Dezimalstellen oder "-" wenn keine Noten vorhanden sind

                    }
                }
            }
            .navigationTitle("Fächerdurchschnitte")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fach hinzufügen") {
                        showingAddSubjectSheet = true // Sheet anzeigen
                    }
                }
            }
            .preferredColorScheme(.light)
            Text("Gesamtdurchschnitt aller Fächer: \(overallAverageText)") // Anzeige Gesamtdurchschnitt oder "-" wenn 0.0
                .padding()
            Text("Maturadurchschnitt: \(maturaAverageText)") // Anzeige Maturadurchschnitt oder "-" wenn 0.0
                .padding()
        }
        .sheet(isPresented: $showingAddSubjectSheet) {
            NavigationStack {
                Form {
                    TextField("Fachname", text: $newSubjectName) // Eingabefeld für den Namen des neuen Faches
                    Toggle("Maturarelevant", isOn: $isMaturarelevant) // Schalter für Maturarelevanz
                }
                .navigationTitle("Neues Fach")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            showingAddSubjectSheet = false // Sheet schliessen wenn abbrechen getippt wird
                            newSubjectName = "" // Reset Fachname
                            isMaturarelevant = false // Reset Maturarelevanz
                        }

                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Hinzufügen") {
                            let newSubject = Subject(name: newSubjectName, isMaturarelevant: isMaturarelevant)
                            semester.subjects.append(newSubject) // Fügt das neue Fach der Liste hinzu
                            showingAddSubjectSheet = false // Sheet schliessen wenn hinzufügen getippt wird
                            newSubjectName = "" // Reset Fachname
                            isMaturarelevant = false // Reset Maturarelevanz
                        }
                        .disabled(newSubjectName.isEmpty) // Deaktiviert den Button wenn kein Name eingegeben wurde

                    }
                }
            }
        }
    }
}


