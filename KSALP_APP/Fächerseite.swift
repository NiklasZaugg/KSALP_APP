import SwiftUI

struct Grade {
    var name: String // Name der Prüfung
    var score: Double // Notenwert
    var weight: Double // Gewichtung der Note
}

struct ContentView: View {
    @State private var subjectName: String = "Fach" // Name des Fachs
    @State private var editingSubjectName: String = "" // Hilfsvariable für das Bearbeiten des Fachnamens
    @State private var grades: [Grade] = [] // Liste der Noten
    @State private var average: Double = 0.0 // Durchschnittswert der Noten
    @State private var showActionSheet: Bool = false // Steuert die Anzeige des ActionSheets (Titel)
    @State private var showingAddGradeSheet: Bool = false // Steuert die Anzeige des Sheets für das Hinzufügen neuer Noten (Prüfung)
    @State private var showingEditSubjectSheet: Bool = false // Steuert die Anzeige des Sheets für das Bearbeiten des Fachnamens
    @State private var newName: String = "" // Eingabefeld für den Namen der neuen Note
    @State private var newScore: String = "" // Eingabefeld für die Punktzahl der neuen Note
    @State private var newWeight: String = "" // Eingabefeld für die Gewichtung der neuen Note

    var body: some View {
        VStack {
            Button(action: {
                self.showActionSheet = true // Zeigt das ActionSheet Titel an
            }) {
                HStack {
                    Text(subjectName).font(.title)
                    Image(systemName: "chevron.down")
                }.foregroundColor(.black)
            }
            .padding()
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Aktion wählen"), message: nil, buttons: [
                    .default(Text("Fachtitel bearbeiten")) {
                        self.editingSubjectName = self.subjectName
                        self.showingEditSubjectSheet = true
                    },
                    .destructive(Text("Fach löschen")) {
                        self.grades.removeAll() // Löscht alle Noten
                        calculateAverage() // Berechnet den Durchschnitt neu
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingEditSubjectSheet) { //Aktiviert das Sheet Fachtitel bearbeiten
                NavigationView {
                    VStack {
                        TextField("Fachtitel eingeben", text: $editingSubjectName)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                    }
                    .navigationBarTitle("Fachtitel bearbeiten", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Abbrechen") {
                            showingEditSubjectSheet = false // Schliesst das Sheet, ohne Änderungen zu speichern
                        },
                        trailing: Button("Fertig") {
                            subjectName = editingSubjectName
                            showingEditSubjectSheet = false // Speichert die Änderungen und schliesst das Sheet
                        }
                    )
                }
            }

            Spacer()
            
            // Durchschnittsanzeige
            Text("Durchschnitt: \(String(format: "%.2f", average))") // Zeigt den Durchschnittswert
            
            // Liste der Noten
            ScrollView {
                VStack {
                    ForEach(grades.indices, id: \.self) { index in
                        HStack {
                            Text(grades[index].name)
                                .frame(width: 100, alignment: .leading)
                            Spacer()
                            Text(String(format: "%.2f", grades[index].score))
                            Spacer()
                            Text(String(format: "%.1f", grades[index].weight))
                            Spacer()
                            Button(action: {
                                grades.remove(at: index) // Löschfunktion für die Note
                                calculateAverage() // Berechnet den Durchschnitt neu
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .foregroundColor(.black)
            
            // Hinzufügen neuer Noten
            Button(action: {
                self.showingAddGradeSheet = true // Aktiviert das Sheet zum Hinzufügen neuer Noten
            }) {
                Text("Neue Note hinzufügen")
            }
            .padding()
            .sheet(isPresented: $showingAddGradeSheet) { // Blatt für das Hinzufügen neuer Noten
                NavigationView {
                    VStack {
                        TextField("Prüfung", text: $newName)
                            .multilineTextAlignment(.center)
                            .padding()
                        TextField("Note", text: $newScore)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad) // Tastaturtyp für Dezimalzahlen
                            .padding()
                        TextField("Gewichtung", text: $newWeight)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad) // Tastaturtyp für Dezimalzahlen
                            .padding()
                    }
                    .navigationBarTitle("Neue Note hinzufügen", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Abbrechen") {
                            showingAddGradeSheet = false // Schliesst das Sheet, ohne Änderungen zu speichern
                        },
                        trailing: Button("Fertig") {
                            addGrade(name: newName, score: Double(newScore) ?? 0.0, weight: Double(newWeight) ?? 1.0)
                            showingAddGradeSheet = false // Schliesst das Sheet nach dem Speichern
                            newName = "" // Setzt die Eingabefelder zurück
                            newScore = ""
                            newWeight = ""
                        }
                    )
                }
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: calculateAverage) // Berechnet den Durchschnitt beim ersten Laden der Ansicht
    }
    
    // Funktion zum Hinzufügen einer neuen Note
    func addGrade(name: String, score: Double, weight: Double) {
        grades.append(Grade(name: name, score: score, weight: weight)) // Fügt die neue Note hinzu
        calculateAverage() // Berechnet den Durchschnitt sofort nach dem Hinzufügen
    }
    
    // Funktion zum Berechnen des Durchschnitts
    func calculateAverage() {
        let validGrades = grades.filter { $0.score >= 0 } // Filtert ungültige Werte heraus
        guard !validGrades.isEmpty else {
            average = 0 // Setzt den Durchschnitt auf 0, wenn keine gültigen Noten vorhanden sind
            return
        }
        
        let totalScore = validGrades.reduce(0) { $0 + ($1.score * $1.weight) } // Summiert gewichtete Scores
        let totalWeight = validGrades.reduce(0) { $0 + $1.weight } // Summiert alle Gewichtungen
        average = totalScore / totalWeight // Berechnet den gewichteten Durchschnitt
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
