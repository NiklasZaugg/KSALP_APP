import SwiftUI

struct Grade {
    var name: String // Name der Prüfung
    var score: Double // Notenwert
    var weight: Double // Gewichtung der Note
    var date: Date // Datum für jede Prüfung
}

struct ContentView: View {
    @State private var subjectName: String  // Name des Fachs
    @State private var editingSubjectName: String = "" // Hilfsvariable für das Bearbeiten des Fachnamens
    @State private var grades: [Grade] = [] // Liste der Noten
    @State private var average: Double = 0.0 // Durchschnittswert der Noten
    @State private var showActionSheet: Bool = false // Steuert die Anzeige des ActionSheets (Titel)
    @State private var showingAddGradeSheet: Bool = false // Steuert die Anzeige des Sheets für das Hinzufügen neuer Noten (Prüfung)
    @State private var showingEditSubjectSheet: Bool = false // Steuert die Anzeige des Sheets für das Bearbeiten des Fachnamens
    @State private var newName: String = "Neue Note" // Eingabefeld für den Namen der neuen Note
    @State private var newScore: String = "" // Eingabefeld für die Punktzahl der neuen Note
    @State private var newWeight: String = "1.0" // Eingabefeld für die Gewichtung der neuen Note
    @State private var newDate: Date = Date() // Standart - heutiges Datum
    
    // Hinzufügen eines Initialisierers -- ermöglich fachnamensynchronisation
    init(subjectName: String) {
        self._subjectName = State(initialValue: subjectName)
    }

    var body: some View {
        NavigationStack{
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
                            NavigationLink(destination: GradeDetailView(grade: $grades[index])
                                .onDisappear(perform: calculateAverage)) { // Berechnet den Durchschnitt neu, wenn Details geändert werden
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(grades[index].name) // Anzeige des Namens
                                            .frame(width: 100, alignment: .leading)
                                        HStack {
                                            Image(systemName: "scalemass") // Symbol für Gewichtung
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 15, height: 15)
                                                .foregroundColor(.gray)
                                            Text(String(format: "%.1f", grades[index].weight)) // Anzeige der Gewichtung
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer() // Trennt den Namen und die Note optisch
                                    Text(String(format: "%.2f", grades[index].score)) // Anzeige der Bewertung
                                        .frame(alignment: .trailing)
                                }
                                .padding()
                            } // Ende des NavigationLink
                        }
                    }
                    .padding()
                }
                .foregroundColor(.black)


                
                // Hinzufügen neuer Noten
                Button(action: {
                    self.newName = "Neue Note" // Setzt den Namen jedes Mal zurück, bevor das Sheet geöffnet wird
                    self.showingAddGradeSheet = true // Aktiviert das Sheet zum Hinzufügen neuer Noten
                }) {
                    Text("Neue Note hinzufügen")
                }
                .padding()
                .sheet(isPresented: $showingAddGradeSheet) { //Anzegige Sheet neue Noten
                    NavigationView {
                        Form {
                            Section(header: Text("Prüfungsdetails").font(.headline)) { //Formular standartform IOS
                                TextField("Prüfung", text: $newName)
                                TextField("Note", text: $newScore)
                                    .keyboardType(.decimalPad)
                                HStack {
                                    Text("Gewichtung:")
                                        .frame(width: 100, alignment: .leading) // Gibt dem Text eine feste Breite
                                    TextField("1.0", text: $newWeight)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 200) // Gibt dem TextField eine feste Breite für Konsistenz
                                }
                                .padding(.vertical, 8) // Gleiches Padding für alle Elemente
                                
                                DatePicker("Datum der Prüfung", selection: $newDate, displayedComponents: .date)
                            }
                        }                    .navigationBarTitle("Neue Note hinzufügen", displayMode: .inline)
                            .navigationBarItems(
                                leading: Button("Abbrechen") {
                                    showingAddGradeSheet = false
                                },
                                trailing: Button("Fertig") {
                                    addGrade(name: newName, score: Double(newScore) ?? 0.0, weight: Double(newWeight) ?? 1.0, date: newDate)
                                    showingAddGradeSheet = false
                                    newName = ""
                                    newScore = ""
                                    newWeight = ""
                                }
                            )
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .onAppear(perform: calculateAverage) // Berechnet den Durchschnitt beim ersten Laden der Ansicht
        
        
        .preferredColorScheme(.light) // Erzwingt Light Mode für View
    }
    
    // Funktion zum Hinzufügen einer neuen Note
    func addGrade(name: String, score: Double, weight: Double, date: Date) { //
        grades.append(Grade(name: name, score: score, weight: weight, date: date)) //Datum wird zu den Noten hinzugefügt
        calculateAverage()
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
        SubjectAveragesView()
    }
}
