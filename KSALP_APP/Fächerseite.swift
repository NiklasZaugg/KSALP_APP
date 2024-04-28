import SwiftUI


struct Grade {
    var name: String
    var score: Double
    var weight: Double
    var date: Date
}

struct Subject {
    var name: String
    var grades: [Grade] = []
    var averageGrade: Double {
        let totalWeight = grades.reduce(0) { $0 + $1.weight }
        let totalScore = grades.reduce(0) { $0 + ($1.score * $1.weight) }
        return totalWeight == 0 ? 0 : totalScore / totalWeight
    }
}



struct ContentView: View {
    @Binding var subject: Subject // Verwende Binding um Änderungen zurückzuspiegeln und synchron zu halten

    @State private var showActionSheet: Bool = false // Steuert die Anzeige des ActionSheets (Titel)
    @State private var showingAddGradeSheet: Bool = false // Steuert die Anzeige des Sheets für das Hinzufügen neuer Noten (Prüfung)
    @State private var showingEditSubjectSheet: Bool = false // Steuert die Anzeige des Sheets für das Bearbeiten des Fachnamens
    @State private var editingSubjectName: String = "" // Hilfsvariable für das Bearbeiten des Fachnamens
    @State private var newName: String = "Neue Note" // Eingabefeld für den Namen der neuen Note
    @State private var newScore: String = "" // Eingabefeld für die Punktzahl der neuen Note
    @State private var newWeight: String = "1.0" // Eingabefeld für die Gewichtung der neuen Note
    @State private var newDate: Date = Date() // Standard - heutiges Datum
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    self.showActionSheet = true // Zeigt das ActionSheet Titel an
                }) {
                    HStack {
                        Text(subject.name).font(.title)
                        Image(systemName: "chevron.down")
                    }.foregroundColor(.black)
                }
                .padding()
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Aktion wählen"), message: nil, buttons: [
                        .default(Text("Fachtitel bearbeiten")) {
                            self.editingSubjectName = self.subject.name
                            self.showingEditSubjectSheet = true
                        },
                        .destructive(Text("Fach löschen")) {
                            self.subject.grades.removeAll() // Löscht alle Noten
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingAddGradeSheet) { // Anzeige Sheet neue Noten
                    NavigationView {
                        Form {
                            TextField("Prüfung", text: $newName)
                            TextField("Note", text: $newScore)
                                .keyboardType(.decimalPad)
                            TextField("Gewichtung", text: $newWeight)
                                .keyboardType(.decimalPad)
                            DatePicker("Datum der Prüfung", selection: $newDate, displayedComponents: .date)
                        }
                        .navigationBarTitle("Neue Note hinzufügen", displayMode: .inline)
                        .navigationBarItems(
                            leading: Button("Abbrechen") {
                                showingAddGradeSheet = false
                                
                                // Reset der Eingabefelder  falls der Benutzer abbricht
                                newName = "Neue Note"
                                newScore = ""
                                newWeight = "1.0"
                                newDate = Date()
                            },
                            trailing: Button("Fertig") {
                                let newGrade = Grade(name: newName, score: Double(newScore) ?? 0, weight: Double(newWeight) ?? 1.0, date: newDate)
                                subject.grades.append(newGrade)
                                showingAddGradeSheet = false // Schliesst das Sheet
                                
                                // Reset der Eingabefelder für die nächste Eingabe
                                newName = "Neue Note"
                                newScore = ""
                                newWeight = "1.0"
                                newDate = Date()
                            }
                        )
                    }
                }


                Spacer()

                Text("Durchschnitt: \(String(format: "%.2f", subject.averageGrade))") // Zeigt den Durchschnittswert

                ScrollView {
                    VStack { // Liste der Prüfungen
                        ForEach(subject.grades.indices, id: \.self) { index in
                            NavigationLink(destination: GradeDetailView(grade: $subject.grades[index])) { // Navigation zu GradeDetailView
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(subject.grades[index].name) // Anzeige des Namens der Prüfung
                                            .frame(width: 100, alignment: .leading)
                                        HStack {
                                            Image(systemName: "scalemass") // Symbol für Gewichtung
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 15, height: 15)
                                                .foregroundColor(.gray)
                                            Text(String(format: "%.1f", subject.grades[index].weight)) // Anzeige der Gewichtung
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer() // Trennt den Namen und die Note optisch
                                    Text(String(format: "%.2f", subject.grades[index].score)) // Anzeige der Bewertung
                                        .frame(alignment: .trailing)
                                }
                                .padding()
                            }
                        }
                    }                }
                .foregroundColor(.black)

                Button(action: {
                    self.showingAddGradeSheet = true // Aktiviert das Sheet zum Hinzufügen neuer Noten
                }) {
                    Text("Neue Note hinzufügen")
                }
                .padding()
                .sheet(isPresented: $showingAddGradeSheet) { // Anzeige Sheet neue Noten
                    NavigationView {
                        Form {
                            TextField("Prüfung", text: $newName)
                            TextField("Note", text: $newScore)
                                .keyboardType(.decimalPad)
                            TextField("Gewichtung", text: $newWeight)
                                .keyboardType(.decimalPad)
                            DatePicker("Datum der Prüfung", selection: $newDate, displayedComponents: .date)
                            Button("Fertig") {
                                let newGrade = Grade(name: newName, score: Double(newScore) ?? 0, weight: Double(newWeight) ?? 1.0, date: newDate)
                                subject.grades.append(newGrade)
                                showingAddGradeSheet = false // Schliesst das Sheet
                            }
                            .padding()
                        }
                        .navigationBarTitle("Neue Note hinzufügen", displayMode: .inline)
                        .navigationBarItems(
                            leading: Button("Abbrechen") {
                                showingAddGradeSheet = false
                            }
                        )
                    }
                }

                Spacer()
            }
        }
        .padding()
        .preferredColorScheme(.light) // Erzwingt Light Mode für View
    }
}
