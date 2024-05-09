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

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) { // Zwei Spalten Grid
                    ForEach(semesterData.semesters) { semester in // Eine Liste die alle Semester anzeigt. Jedes Semester ist ein klickbarer NavigationLink
                        NavigationLink(destination: SubjectAveragesView(semester: semester)) {
                            Text(semester.name)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, minHeight: 100) // Konstante Textfeldgrösse für alle Semester
                                .lineLimit(2) // Limitiert den Text auf 2 Zeilen
                                .truncationMode(.tail) // Fügt "..." am Ende des Texts hinzu wenn zu lang
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                        .buttonStyle(PlainButtonStyle()) // Entfernt den Standard-Pfeil von NavigationLink
                    }
                }
                .padding()
            }
            .navigationTitle("Semester Übersicht")
            .toolbar {
                Button(action: {//Button: Neue Semester
                    self.showingAddSemester = true
                }) {
                    Image(systemName: "plus")
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
    
    func addSemester(name: String) {
        let newSemester = Semester(name: name)
        semesters.append(newSemester)
    }
}

struct SemesterView_Previews: PreviewProvider {
    static var previews: some View {
        SemesterView()
    }
}

class Semester: ObservableObject, Identifiable { //?
    let id = UUID()
    let name: String
    @Published var subjects: [Subject]

    init(name: String, subjects: [Subject] = []) {
        self.name = name
        self.subjects = subjects
    }
}

