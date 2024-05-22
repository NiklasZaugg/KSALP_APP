import SwiftUI


struct Grade {
    var name: String
    var score: Double
    var weight: Double
    var date: Date
    var isFinalExam: Bool //Eigenschaft zur Kennzeichnung von Abschlussprüfungen für Design
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
    @ObservedObject var semester: Semester // Hinzugefügt, um die Liste der Fächer zu aktualisieren für das Fachlöschen
    
    
    
    @State private var showActionSheet: Bool = false // Steuert die Anzeige des ActionSheets (Titel)
    @State private var showingAddGradeSheet: Bool = false // Steuert die Anzeige des Sheets für das Hinzufügen neuer Noten (Prüfung)
    @State private var showingEditSubjectSheet: Bool = false // Steuert die Anzeige des Sheets für das Bearbeiten des Fachnamens
    @State private var editingSubjectName: String = "" // Hilfsvariable für das Bearbeiten des Fachnamens
    @State private var editingIsMaturarelevant: Bool = false // Hilfsvariable für das Bearbeiten der Maturarelevanz
    @State private var showAdditionalOptions: Bool = false // Steuert die Anzeige der zusätzlichen Optionen
    @State private var showingAddFinalExamSheet: Bool = false // Steuert die Anzeige des Sheets für das Hinzufügen einer Abschlussprüfung
    @State private var showingCalculatorSheet: Bool = false // Steuert die Anzeige des Wunschnotenrechners
    @State private var newName: String = "Neue Note" // Eingabefeld für den Namen der neuen Note
    @State private var newScore: String = "" // Eingabefeld für die Punktzahl der neuen Note
    @State private var newWeight: String = "1.0" // Eingabefeld für die Gewichtung der neuen Note
    @State private var newDate: Date = Date() // Standard - heutiges Datum
    @State private var finalExamName: String = "Abschlussprüfung" // Eingabefeld für den Namen der Abschlussprüfung
    @State private var finalExamScore: String = "" // Eingabefeld für die Punktzahl der Abschlussprüfung
    @State private var finalExamDate: Date = Date() // Standard - heutiges Datum
    @State private var desiredGrade: String = "" // Eingabefeld für den gewünschten Durchschnitt
    @State private var desiredWeight: String = "1.0" // Eingabefeld für die Gewichtung der gewünschten Note
    @State private var requiredScore: String = "" // Ausgabe der benötigten Note
    @Environment(\.presentationMode) var presentationMode // Um die View zu schliessen für das Fachlöschen
    
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Text("Durchschnitt")
                            Text(subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade)) // Zeigt den Durchschnittswert oder "-" wenn keine Noten vorhanden sind
                        }
                        .padding(.top)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("Zeugnisnote")
                            Text(subject.grades.isEmpty ? "-" : String(format: "%.1f", subject.roundedAverageGrade)) // Zeigt gerundeter Durchschnitt an
                        }
                        .padding(.top)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    
                    
                    ScrollView {
                        VStack(spacing: 8) { // Abstand der Prüfungen
                            ForEach(subject.grades.indices, id: \.self) { index in
                                NavigationLink(destination: GradeDetailView(grade: $subject.grades[index])) { // Navigation zu GradeDetailView
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(subject.grades[index].name) // Anzeige des Namens der Prüfung
                                                .font(.headline)
                                                .lineLimit(1)
                                                .truncationMode(.tail) // Text abschneiden mit "..."
                                                .frame(maxWidth: .infinity, alignment: .leading) // Maximale Breite auf die verfügbare Breite begrenzen
                                                .padding(.trailing, 8)
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
                                            .font(.headline)
                                            .frame(alignment: .trailing)
                                    }
                                    .padding(8)
                                    .background(subject.grades[index].isFinalExam ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)) // Hintergrundfarbe für Abschlussprüfung und normale Noten
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(subject.grades[index].isFinalExam ? Color.blue : Color.clear, lineWidth: 2) // Rahmenfarbe für Abschlussprüfung und keine Rahmenfarbe für normale Noten
                                    )
                                    .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2) // Leichte Schattierung
                                }
                            }
                        }
                        .padding()
                    }
                    .foregroundColor(.black)
                    

                    

                    
                    
                        .sheet(isPresented: $showingAddGradeSheet) { // Anzeige Sheet neue Noten
                            NavigationView {
                                Form {
                                    Section {
                                        TextField("Titel", text: $newName)
                                    }
                                    .padding(.bottom, 20)
                                    
                                    Section {
                                        HStack {
                                            Text("Datum der Prüfung:")
                                            Spacer()
                                            DatePicker("", selection: $newDate, displayedComponents: .date)
                                                .labelsHidden()
                                        }
                                    }
                                    .padding(.bottom, 20)
                                    
                                    Section {
                                        HStack {
                                            TextField("Note", text: $newScore)
                                                .keyboardType(.decimalPad)
                                        }
                                        
                                        HStack {
                                            Text("Gewichtung:")
                                            Spacer()
                                            TextField("", text: $newWeight)
                                                .keyboardType(.decimalPad)
                                                .multilineTextAlignment(.trailing)
                                        }
                                    }
                                }
                                .navigationBarTitle("Neue Note hinzufügen", displayMode: .inline)
                                .navigationBarItems(
                                    leading: Button("Abbrechen") {
                                        showingAddGradeSheet = false
                                        
                                        // Reset der Eingabefelder falls der Benutzer abbricht
                                        newName = "Neue Note"
                                        newScore = ""
                                        newWeight = "1.0"
                                        newDate = Date()
                                    },
                                    trailing: Button("Fertig") {
                                        let newGrade = Grade(name: newName, score: Double(newScore) ?? 0, weight: Double(newWeight) ?? 1.0, date: newDate, isFinalExam: false)
                                        subject.grades.append(newGrade)
                                        
                                        // Aktualisiert die Gewichtung der bestehenden Abschlussprüfungen
                                        let totalNonFinalExamWeight = subject.grades.filter { !$0.isFinalExam }.reduce(0) { $0 + $1.weight }
                                        let finalExamGrades = subject.grades.filter { $0.isFinalExam }
                                        let totalFinalExamWeight = totalNonFinalExamWeight // Abschlussprüfungen machen die Hälfte des Gesamtgewichts aus
                                        let individualFinalExamWeight = finalExamGrades.isEmpty ? 0 : totalFinalExamWeight / Double(finalExamGrades.count)
                                        for index in subject.grades.indices {
                                            if subject.grades[index].isFinalExam {
                                                subject.grades[index].weight = individualFinalExamWeight
                                            }
                                        }
                                        
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
                                Text(subject.name)//Fachtitel
                                    .font(.headline)
                                    .lineLimit(1) // Begrenzung auf eine Zeile
                                    .truncationMode(.tail) // Text abschneiden mit "..."
                                    .frame(maxWidth: 200, alignment: .leading) // Maximale Breite des Fachtitels
                                Image(systemName: "chevron.down")
                            }.foregroundColor(.black)
                        }
                        .actionSheet(isPresented: $showActionSheet) {
                            ActionSheet(title: Text("Aktion wählen"), message: nil, buttons: [
                                .default(Text("Fach bearbeiten")) {
                                    self.editingSubjectName = self.subject.name
                                    self.editingIsMaturarelevant = self.subject.isMaturarelevant
                                    self.showingEditSubjectSheet = true
                                },
                                .destructive(Text("Fach löschen")) {
                                    self.semester.subjects.removeAll { $0.id == self.subject.id } // Löscht das Fach aus der Liste
                                    self.presentationMode.wrappedValue.dismiss() // Schliesst die aktuelle View
                                },
                                .cancel()
                            ])
                        }
                    }
                }
                .sheet(isPresented: $showingEditSubjectSheet) { // Anzeige Sheet "Fach Bearbeiten"
                    NavigationView {
                        Form {
                            TextField("Fachname", text: $editingSubjectName)//Textfeld Fachtitel
                            Toggle("Maturarelevant", isOn: $editingIsMaturarelevant)
                        }
                        .navigationBarTitle("Fach bearbeiten", displayMode: .inline)
                        .navigationBarItems(leading: Button("Abbrechen") {
                            self.showingEditSubjectSheet = false
                        }, trailing: Button("Fertig") {
                            self.subject.name = self.editingSubjectName
                            self.subject.isMaturarelevant = self.editingIsMaturarelevant
                            self.showingEditSubjectSheet = false
                        })
                    }
                }
                .sheet(isPresented: $showingAddFinalExamSheet) { // Anzeige Sheet Abschlussprüfung
                    NavigationView {
                        Form {
                            Section{
                                TextField("Abschlussprüfung", text: $finalExamName) // Eingabefeld für den Namen der Abschlussprüfung
                                TextField("Note", text: $finalExamScore) // Eingabefeld für die Punktzahl der Abschlussprüfung
                                    .keyboardType(.decimalPad)
                            }
                            DatePicker("Datum der Prüfung", selection: $finalExamDate, displayedComponents: .date) // Datum der Abschlussprüfung
                        }
                        .navigationBarTitle("Abschlussprüfung hinzufügen", displayMode: .inline)
                        .navigationBarItems(
                            leading: Button("Abbrechen") {
                                showingAddFinalExamSheet = false
                                
                                // Reset der Eingabefelder falls der Benutzer abbricht
                                finalExamName = "Abschlussprüfung"
                                finalExamScore = ""
                                finalExamDate = Date()
                            },
                            trailing: Button("Fertig") {
                                let totalNonFinalExamWeight = subject.grades.filter { !$0.isFinalExam }.reduce(0) { $0 + $1.weight }
                                let finalExamGrades = subject.grades.filter { $0.isFinalExam }
                                let finalExamCount = finalExamGrades.count + 1
                                let totalFinalExamWeight = totalNonFinalExamWeight // Abschlussprüfungen machen die Hälfte des Gesamtgewichts aus
                                let individualFinalExamWeight = totalFinalExamWeight / Double(finalExamCount)
                                
                                // Aktualisiere die Gewichtung der bestehenden Abschlussprüfungen
                                for index in subject.grades.indices {
                                    if subject.grades[index].isFinalExam {
                                        subject.grades[index].weight = individualFinalExamWeight
                                    }
                                }
                                
                                let newGrade = Grade(name: finalExamName, score: Double(finalExamScore) ?? 0, weight: individualFinalExamWeight, date: finalExamDate, isFinalExam: true)
                                subject.grades.append(newGrade)
                                showingAddFinalExamSheet = false // Schliesst das Sheet
                                
                                // Reset der Eingabefelder für die nächste Eingabe
                                finalExamName = "Abschlussprüfung"
                                finalExamScore = ""
                                finalExamDate = Date()
                            }
                                .disabled(finalExamScore.isEmpty) // Deaktiviert den Button, wenn finalExamScore leer ist
                        )
                    }
                }
                .sheet(isPresented: $showingCalculatorSheet) { // Anzeige des Sheets für den Wunschnotenrechner
                    NavigationView {
                        Form {
                            Section(header: Text("Wunschnote eingeben")) {
                                HStack {
                                    TextField("Gewünschter Durchschnitt:", text: $desiredGrade)
                                        .keyboardType(.decimalPad)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            Section(header: Text("Gewichtung eingeben")) {
                                HStack {
                                    TextField("Gewichtung", text: $desiredWeight)
                                        .keyboardType(.decimalPad)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            Section() {
                                HStack {
                                    Text("Benötigte Note:")
                                    Spacer()
                                    TextField("", text: $requiredScore)
                                        .disabled(true) // Das Feld für die benötigte Note ist deaktiviert und wird berechnet
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        .navigationBarTitle("Wunschnotenrechner", displayMode: .inline)
                        .navigationBarItems(
                            leading: Button("Abbrechen") {
                                showingCalculatorSheet = false
                                
                                // Reset der Eingabefelder falls der Benutzer abbricht
                                desiredGrade = ""
                                desiredWeight = "1.0"
                                requiredScore = ""
                            },
                            trailing: Button("Berechnen") {
                                let desiredAverage = Double(desiredGrade) ?? 0
                                let weight = Double(desiredWeight) ?? 1.0
                                let totalCurrentWeight = subject.grades.reduce(0) { $0 + $1.weight }
                                let totalCurrentScore = subject.grades.reduce(0) { $0 + ($1.score * $1.weight) }
                                
                                let requiredScoreValue = (desiredAverage * (totalCurrentWeight + weight) - totalCurrentScore) / weight
                                requiredScore = String(format: "%.2f", requiredScoreValue)
                            }
                        )
                    }
                }
                
                
            }
            .preferredColorScheme(.light) // Erzwingt Light Mode für View
            VStack {
                Button(action: {
                    self.showAdditionalOptions.toggle() // Umschalten der Anzeige der zusätzlichen Optionen
                }) {
                    Image(systemName: self.showAdditionalOptions ? "x.circle" : "plus.circle") // Symbol ändern
                        .font(.largeTitle)
                }
                .padding()

                if showAdditionalOptions {
                    VStack(spacing: 10) {
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {//Verzögerung schliessen des Buttons
                                self.showAdditionalOptions = false // Schliesst das Menü nach Auswahl
                            }
                            self.showingAddGradeSheet = true // Aktiviert das Sheet zum Hinzufügen neuer Noten
                        }) {
                            HStack {
                                Text("Note hinzufügen")
                                Spacer()
                                Image(systemName: "plus.square")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.2)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .shadow(color: Color.blue.opacity(0.5), radius: 3, x: 0, y: 2)
                        }
                        
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {//Verzögerung schliessen des Buttons
                                self.showAdditionalOptions = false // Schliesst das Menü nach Auswahl
                            }
                            self.showingAddFinalExamSheet = true // Aktiviert das Sheet zum Hinzufügen einer Abschlussprüfung
                        }) {
                            HStack {
                                Text("Abschlussprüfung hinzufügen")
                                Spacer()
                                Image(systemName: "checkmark.square")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.2)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .shadow(color: Color.blue.opacity(0.5), radius: 3, x: 0, y: 2)
                        }
                        .disabled(subject.grades.isEmpty) // Deaktiviert den Button wenn keine Noten vorhanden sind
                        
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {//Verzögerung schliessen des Buttons
                                self.showAdditionalOptions = false // Schliesst das Menü nach Auswahl
                            }
                            self.showingCalculatorSheet = true // Aktiviert das Sheet für den Wunschnotenrechner
                        }) {
                            HStack {
                                Text("Wunschnotenrechner")
                                Spacer()
                                Image(systemName: "calculator")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.2)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .shadow(color: Color.blue.opacity(0.5), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .padding()
        }
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


