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
            ScrollView { 
                VStack(spacing: 4) { // Reduziert den Abstand zwischen den Elementen weiter
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gesamtdurchschnitt ") // Text für Gesamtdurchschnitt
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(overallAverageText) // Anzeige des Gesamtdurchschnitts
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        VStack(alignment: .leading) {
                            Text("Maturadurchschnitt") // Text für Maturadurchschnitt
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(maturaAverageText) // Anzeige des Maturadurchschnitts
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    .frame(height: 100) // Sicherstellen, dass die beiden Durchschnittsanzeigen gleich gross sind
                    
                    Text("Fächer") // Überschrift für die Fächerliste
                        .font(.title)
                        .bold()
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .background(Color.white)
                        .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)

                    VStack(spacing: 0) {
                        ForEach($semester.subjects, id: \.id) { $subject in // Die Verwendung von .id gewährleistet eine eindeutige Identifikation der Listenelemente
                            NavigationLink(destination: ContentView(subject: $subject, semester: semester)) { // Übergeben des semester-Objekts
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(subject.name) // Anzeige des Namens des Faches
                                            .foregroundColor(.black) // Setzt die Schriftfarbe auf schwarz
                                            .lineLimit(1) // Begrenzung auf eine Zeile
                                            .truncationMode(.tail) // Text abschneiden mit "..."
                                            .frame(maxWidth: .infinity, alignment: .leading) // Maximale Breite auf die verfügbare Breite begrenzen
                                        if subject.isMaturarelevant {
                                            Text("Matura") // Anzeige des Textes "Matura" wenn das Fach maturarelevant ist
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("") // Platzhalter um die Höhe konsistent zu halten
                                                .font(.caption)
                                                .foregroundColor(.clear)
                                        }
                                    }
                                    Spacer()
                                    Text(subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade)) // Anzeige des Durchschnitts des Faches auf zwei Dezimalstellen oder "-" wenn keine Noten vorhanden sind
                                        .foregroundColor(.black) // Setzt die Schriftfarbe auf schwarz
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, minHeight: 50) // Setzt die maximale Breite und eine Mindesthöhe
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                                .padding([.leading, .trailing], 4) // Fügt Paddings links und rechts hinzu
                            }
                            .listRowInsets(EdgeInsets()) // Entfernt die Standardeinrückungen
                        }
                    }
                    .padding([.leading, .trailing], 8) // Fügt Paddings links und rechts zur gesamten Liste hinzu
                }
                .navigationTitle(semester.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fach hinzufügen") {
                            showingAddSubjectSheet = true // Sheet anzeigen
                        }
                    }
                }
                .preferredColorScheme(.light)
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
}
