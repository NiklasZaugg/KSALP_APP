//
//  SemesterView.swift
//  KSALP_APP
//
//  Created by Niklas on 29.04.24.
//

import SwiftUI

struct SemesterView: View {
    @StateObject var semesterData = SemesterData() // @StateObject sorgt dafür dass die View auf Änderungen im SemesterData reagiert

    @State private var showingAddSemester = false
    @State private var newSemesterName = ""
    @State private var isEditing = false // Zustand Semesterbearbeitungsmodus
    @State private var selectedSemester: Semester? // Ausgewähltes Semester für die Semester Namens Bearbeitung

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) { // Zwei Spalten Grid
                    ForEach(semesterData.semesters) { semester in // Eine Liste die alle Semester anzeigt. Jedes Semester ist ein klickbarer NavigationLink
                        ZStack(alignment: .topLeading) { // ZStack für die Kombination aus NavigationLink und Löschbutton
                            if isEditing { // Lösch- und Bearbeitungsbutton nur im Bearbeitungsmodus anzeigen
                                HStack {
                                    Button(action: {
                                        semesterData.removeSemester(semester: semester) //Semester löschen
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .resizable() // Button grössenveränderbar
                                            .frame(width: 30, height: 30) // Buttongrösse erhöhen
                                            .foregroundColor(.red)
                                            .background(Color.white) // Hintergrundfarbe hinzugefügt für bessere Sichtbarkeit
                                            .clipShape(Circle()) // Button als Kreisform
                                            .shadow(radius: 3)
                                            .padding(5)
                                    }
                                    Button(action: {
                                        self.selectedSemester = semester // Semester zum Bearbeiten auswählen
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .resizable() // Button grössenveränderbar
                                            .frame(width: 30, height: 30) // Buttongrösse erhöhen
                                            .foregroundColor(.blue)
                                            .background(Color.white) // Hintergrundfarbe hinzugefügt für bessere Sichtbarkeit
                                            .clipShape(Circle()) // Button als Kreisform
                                            .shadow(radius: 3)
                                            .padding(5)
                                    }
                                }
                                .offset(x: -10, y: -10) // Buttons leicht verschoben
                                .zIndex(1) // Buttons im Vordergrund
                            }
                            NavigationLink(destination: SubjectAveragesView(semester: semester)) { // NavigationLink für jedes Semester
                                Text(semester.name)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 100) // Konstante Textfeldgrösse für alle Semester
                                    .lineLimit(2) // Limitiert den Text auf 2 Zeilen
                                    .truncationMode(.tail) // Fügt "..." am Ende des Texts hinzu wenn zu lang
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }                            .buttonStyle(PlainButtonStyle()) // Entfernt den Standard-Pfeil von NavigationLink
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Semester Übersicht")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { // Bearbeiten/Fertig Button
                    Button(action: {
                        isEditing.toggle() // Bearbeitungsmodus umschalten
                    }) {
                        Text(isEditing ? "Fertig" : "Bearbeiten") //Text basierend auf dem Bearbeitungszustand
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) { //Button: Neue Semester
                    Button(action: {
                        self.showingAddSemester = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSemester) { // Anzeige Sheet: Semester hinzufügen
                NavigationView {
                    VStack(spacing: 20) {
                        TextField("Neuer Semestername", text: $newSemesterName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    .padding()
                    .navigationTitle("Semester hinzufügen") // Titel der Navigation Bar
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Abbrechen") {
                                showingAddSemester = false // Schliesst das Sheet
                                newSemesterName = "" // Setzt das Textfeld zurück
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Fertig") {
                                if !newSemesterName.isEmpty {
                                    semesterData.addSemester(name: newSemesterName)
                                    newSemesterName = "" // Setzt das Textfeld zurück
                                    showingAddSemester = false // Schliesst das Sheet
                                }
                            }
                            .disabled(newSemesterName.isEmpty) // Deaktiviert den Button wenn kein Name eingegeben wurde
                        }
                    }
                }
            }
            .sheet(item: $selectedSemester) { semester in // Anzeige Sheet: Semester bearbeiten
                NavigationView {
                    VStack(spacing: 20) {
                        TextField("Semestername bearbeiten", text: Binding(
                            get: { semester.name },
                            set: { newName in
                                if let index = semesterData.semesters.firstIndex(where: { $0.id == semester.id }) {
                                    semesterData.semesters[index].name = newName
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    }
                    .padding()
                    .navigationTitle("Semester bearbeiten") // Titel der Navigation Bar
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Abbrechen") {
                                self.isEditing = false // Schliesst das Sheet und beendet den Bearbeitungsmodus
                                selectedSemester = nil // Setzt das ausgewählte Semester zurück
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Fertig") {
                                self.isEditing = false // Schliesst das Sheet und beendet den Bearbeitungsmodus
                                selectedSemester = nil // Setzt das ausgewählte Semester zurück
                            }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

class SemesterData: ObservableObject { //Class verwaltet die Daten der Semester.
    @Published var semesters: [Semester] = [ // @Published ermöglicht es der View auf Änderungen zu reagieren
        Semester(name: "Sommersemester 2024"),
        Semester(name: "Wintersemester 2024"),
        Semester(name: "Sommersemester 2025")
    ]

    func addSemester(name: String) {// Funktion Semester hinhzufügen
        let newSemester = Semester(name: name)
        semesters.append(newSemester)
    }
    
    func removeSemester(semester: Semester) { // Methode zum Entfernen eines Semesters
        if let index = semesters.firstIndex(where: { $0.id == semester.id }) {
            semesters.remove(at: index)
        }
    }
}

struct SemesterView_Previews: PreviewProvider {
    static var previews: some View {
        SemesterView()
    }
}

class Semester: ObservableObject, Identifiable { //?
    let id = UUID()
    @Published var name: String
    @Published var subjects: [Subject]

    init(name: String, subjects: [Subject] = []) {
        self.name = name
        self.subjects = subjects
    }
}
