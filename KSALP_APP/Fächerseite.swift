import SwiftUI


struct Grade {
    var name: String
    var score: Double
    var weight: Double
    var date: Date
}

struct Subject: Identifiable {
    let id = UUID() // Eindeutiger Identifier für jedes Fach
    var name: String
    var grades: [Grade] = []
    var isMaturarelevant: Bool
    var averageGrade: Double {
        let totalWeight = grades.reduce(0) { $0 + $1.weight }
        let totalScore = grades.reduce(0) { $0 + ($1.score * $1.weight) }
        return totalWeight == 0 ? 0 : totalScore / totalWeight
    }
    var roundedAverageGrade: Double {
        let average = averageGrade
        let rounded = (average * 2).rounded() / 2
        return rounded
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
                HStack {
                    VStack {
                        Text("Durchschnitt")
                        Text(subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade)) // Zeigt den Durchschnittswert oder "-" wenn keine Noten vorhanden sind
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Zeugnisnote")
                        Text(subject.grades.isEmpty ? "-" : String(format: "%.1f", subject.roundedAverageGrade)) // Zeigt gerundeter Durchschnitt an
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

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
                                            Text(subject.grades[index].weight.formattedAsInput()) // Dynamische Anzeige der Gewichtung
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer() // Trennt den Namen und die Note optisch
                                    Text(subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.grades[index].score))//Anzeige der Bewertung der einzelnen Noten
                                        .frame(alignment: .trailing)
                                }
                                .padding()
                            }
                        }
                    }
                }
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
                                .disabled(newScore.isEmpty) // Deaktiviert den Button, wenn newScore leer ist
                             )
                    }
                }


                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline) // Setze den NavigationBarTitle-DisplayMode auf inline
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        self.showActionSheet = true // Zeigt das ActionSheet Titel an
                    }) {
                        HStack {
                            Text(subject.name).font(.title)
                            Image(systemName: "chevron.down")
                        }.foregroundColor(.black)
                    }
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
                }
            }
            .sheet(isPresented: $showingEditSubjectSheet) { // Anzeige Sheet Fachtitel Bearbeiten
                NavigationView {
                    Form {
                        TextField("Fachname", text: $editingSubjectName)
                    }
                    .navigationBarTitle("Fachname bearbeiten", displayMode: .inline)
                    .navigationBarItems(leading: Button("Abbrechen") {
                        self.showingEditSubjectSheet = false
                    }, trailing: Button("Fertig") {
                        self.subject.name = self.editingSubjectName
                        self.showingEditSubjectSheet = false
                    })
                }
            }
        }
        .preferredColorScheme(.light) // Erzwingt Light Mode für View
    }
}


extension Double { // logik formatierungsstring für Gewichtung
    func formattedAsInput() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        
        let stringValue = String(describing: self)
        let decimalPart = stringValue.split(separator: ".").last ?? ""
        let fractionDigits = decimalPart.count

        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

