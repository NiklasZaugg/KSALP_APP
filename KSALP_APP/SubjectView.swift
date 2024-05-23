import SwiftUI

struct Grade: Identifiable {
    let id = UUID()
    var name: String
    var score: Double
    var weight: Double
    var date: Date
    var isFinalExam: Bool
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

struct SubjectView: View {
    @Binding var subject: Subject // Verwende Binding um änderungen zurückzuspiegeln und synchron zu halten
    @ObservedObject var semester: Semester // Hinzugefügt, um die Liste der Faecher zu aktualisieren für das Fachloeschen
    
    @State private var showActionSheet: Bool = false // Steuert die Anzeige des ActionSheets (Titel)
    @State private var showingAddGradeSheet: Bool = false // Steuert die Anzeige des Sheets für das Hinzufuegen neuer Noten (Prüfung)
    @State private var showingEditSubjectSheet: Bool = false // Steuert die Anzeige des Sheets für das Bearbeiten des Fachnamens
    @State private var editingSubjectName: String = "" // Hilfsvariable für das Bearbeiten des Fachnamens
    @State private var editingIsMaturarelevant: Bool = false // Hilfsvariable für das Bearbeiten der Maturarelevanz
    @State private var showAdditionalOptions: Bool = false // Steuert die Anzeige der zusätzlichen Optionen
    @State private var showingAddFinalExamSheet: Bool = false // Steuert die Anzeige des Sheets für das Hinzufuegen einer Abschlussprüfung
    @State private var showingCalculatorSheet: Bool = false // Steuert die Anzeige des Wunschnotenrechners
    @State private var newName: String = "Neue Note" // Eingabefeld für den Namen der neuen Note
    @State private var newScore: String = "" // Eingabefeld für die Punktzahl der neuen Note
    @State private var newWeight: String = "1.0" // Eingabefeld für die Gewichtung der neuen Note
    @State private var newDate: Date = Date() // Standard - heutiges Datum
    @State private var finalExamName: String = "Abschlusspruefung" // Eingabefeld fuer den Namen der Abschlussprüfung
    @State private var finalExamScore: String = "" // Eingabefeld für die Punktzahl der Abschlussprüfung
    @State private var finalExamDate: Date = Date() // Standard - heutiges Datum
    @State private var desiredGrade: String = "" // Eingabefeld fuer den gewünschten Durchschnitt
    @State private var desiredWeight: String = "1.0" // Eingabefeld fuer die Gewichtung der gewünschten Note
    @State private var requiredScore: String = "" // Ausgabe der benötigten Note
    @Environment(\.presentationMode) var presentationMode // Um die View zu schliessen für das Fachlöschen
    @State private var selectedGrade: Grade?

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    averageAndRoundedGradeView
                    gradesListView
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        titleView
                    }
                }
                .sheet(isPresented: $showingAddGradeSheet) {
                    addGradeSheet
                }
                .sheet(isPresented: $showingEditSubjectSheet) {
                    editSubjectSheet
                }
                .sheet(isPresented: $showingAddFinalExamSheet) {
                    addFinalExamSheet
                }
                .sheet(isPresented: $showingCalculatorSheet) {
                    calculatorSheet
                }
                .sheet(item: $selectedGrade) { grade in
                    GradeDetailView(grade: Binding(
                        get: { grade },
                        set: { updatedGrade in
                            if let index = subject.grades.firstIndex(where: { $0.id == updatedGrade.id }) {
                                subject.grades[index] = updatedGrade
                            }
                        }
                    ))
                }

            }
            .preferredColorScheme(.light)
            additionalOptionsView
        }
    }
    
    // Ansicht für Durchschnitt und gerundeten Durchschnitt
    private var averageAndRoundedGradeView: some View {
        HStack {
            VStack {
                Text("Durchschnitt")
                let averageText = subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade)
                Text(averageText)
            }
            .padding(.top)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            .frame(maxWidth: .infinity)
            
            VStack {
                Text("Zeugnisnote")
                let roundedText = subject.grades.isEmpty ? "-" : String(format: "%.1f", subject.roundedAverageGrade)
                Text(roundedText)
            }
            .padding(.top)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    private var gradesListView: some View {
        VStack(spacing: 8) {
            ForEach(subject.grades.indices, id: \.self) { index in
                Button(action: {
                    selectedGrade = subject.grades[index]
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(subject.grades[index].name)
                                .font(.headline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, 8)
                            HStack {
                                Image(systemName: "scalemass")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.gray)
                                Text(subject.grades[index].weight.formattedAsInput())
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer().frame(width: 8)
                                Image(systemName: "calendar")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.gray)
                                Text(formattedDate(subject.grades[index].date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        let scoreText = String(format: "%.2f", subject.grades[index].score)
                        Text(subject.grades.isEmpty ? "-" : scoreText)
                            .font(.headline)
                            .frame(alignment: .trailing)
                    }
                    .padding(8)
                    .background(subject.grades[index].isFinalExam ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(subject.grades[index].isFinalExam ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
        }
        .padding()
        .foregroundColor(.black)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    
    // Ansicht für den Titel und die Aktionen
    private var titleView: some View {
        Button(action: {
            self.showActionSheet = true
        }) {
            HStack {
                Text(subject.name)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 200, alignment: .leading)
                Image(systemName: "chevron.down")
            }.foregroundColor(.black)
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Aktion waehlen"), message: nil, buttons: [
                .default(Text("Fach bearbeiten")) {
                    self.editingSubjectName = self.subject.name
                    self.editingIsMaturarelevant = self.subject.isMaturarelevant
                    self.showingEditSubjectSheet = true
                },
                .destructive(Text("Fach loeschen")) {
                    self.semester.subjects.removeAll { $0.id == self.subject.id }
                    self.presentationMode.wrappedValue.dismiss()
                },
                .cancel()
            ])
        }
    }
    
    // Ansicht für zusätzliche Optionen
    private var additionalOptionsView: some View {
        VStack {
            Button(action: {
                self.showAdditionalOptions.toggle()
            }) {
                Image(systemName: self.showAdditionalOptions ? "x.circle" : "plus.circle")
                    .font(.largeTitle)
            }
            .padding()
            
            if showAdditionalOptions {
                VStack(spacing: 10) {
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showAdditionalOptions = false
                        }
                        self.showingAddGradeSheet = true
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showAdditionalOptions = false
                        }
                        self.showingAddFinalExamSheet = true
                    }) {
                        HStack {
                            Text("Abschlussprüfung hinzufuegen")
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
                    .disabled(subject.grades.isEmpty)
                    
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showAdditionalOptions = false
                        }
                        self.showingCalculatorSheet = true
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
    
    // Sheet für das Hinzufuegen einer neuen Note
    private var addGradeSheet: some View {
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
                    resetAddGradeFields()
                },
                trailing: Button("Fertig") {
                    addNewGrade()
                    showingAddGradeSheet = false
                    resetAddGradeFields()
                }
                .disabled(newScore.isEmpty)
            )
        }
    }
    
    // Sheet für das Bearbeiten eines Fachs
    private var editSubjectSheet: some View {
        NavigationView {
            Form {
                TextField("Fachname", text: $editingSubjectName)
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
    
    // Sheet für das Hinzufügen einer Abschlussprüfung
    private var addFinalExamSheet: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Abschlusspruefung", text: $finalExamName)
                    TextField("Note", text: $finalExamScore)
                        .keyboardType(.decimalPad)
                }
                DatePicker("Datum der Pruefung", selection: $finalExamDate, displayedComponents: .date)
            }
            .navigationBarTitle("Abschlussprüfung hinzufuegen", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    showingAddFinalExamSheet = false
                    resetAddFinalExamFields()
                },
                trailing: Button("Fertig") {
                    addNewFinalExam()
                    showingAddFinalExamSheet = false
                    resetAddFinalExamFields()
                }
                .disabled(finalExamScore.isEmpty)
            )
        }
    }
    
    // Sheet für den Wunschnotenrechner
    private var calculatorSheet: some View {
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
                            .disabled(true)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationBarTitle("Wunschnotenrechner", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    showingCalculatorSheet = false
                    resetCalculatorFields()
                },
                trailing: Button("Berechnen") {
                    calculateRequiredScore()
                }
            )
        }
    }
    
    // Hilfsfunktion zum Zuruecksetzen der Felder für das Hinzufügen einer Note
    private func resetAddGradeFields() {
        newName = "Neue Note"
        newScore = ""
        newWeight = "1.0"
        newDate = Date()
    }
    
    // Hilfsfunktion zum Hinzufügen einer neuen Note
    private func addNewGrade() {
        let scoreValue = Double(newScore) ?? 0
        let weightValue = Double(newWeight) ?? 1.0
        let newGrade = Grade(name: newName, score: scoreValue, weight: weightValue, date: newDate, isFinalExam: false)
        subject.grades.append(newGrade)
        
        updateFinalExamWeights()
    }
    
    // Hilfsfunktion zum Zurücksetzen der Felder für das Hinzufügen einer Abschlussprüfung
    private func resetAddFinalExamFields() {
        finalExamName = "Abschlussprüfung"
        finalExamScore = ""
        finalExamDate = Date()
    }
    
    // Hilfsfunktion zum Hinzufügen einer neuen Abschlussprüfung
    private func addNewFinalExam() {
        let scoreValue = Double(finalExamScore) ?? 0
        let nonFinalGrades = subject.grades.filter { !$0.isFinalExam }
        let totalNonFinalExamWeight = nonFinalGrades.reduce(0) { $0 + $1.weight }
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
        
        let newGrade = Grade(name: finalExamName, score: scoreValue, weight: individualFinalExamWeight, date: finalExamDate, isFinalExam: true)
        subject.grades.append(newGrade)
    }
    
    // Hilfsfunktion zum Zurücksetzen der Felder des Wunschnotenrechners
    private func resetCalculatorFields() {
        desiredGrade = ""
        desiredWeight = "1.0"
        requiredScore = ""
    }
    
    // Hilfsfunktion zur Berechnung der benoetigten Note
    private func calculateRequiredScore() {
        let desiredAverage = Double(desiredGrade) ?? 0
        let weight = Double(desiredWeight) ?? 1.0
        let totalCurrentWeight = subject.grades.reduce(0) { $0 + $1.weight }
        let totalCurrentScore = subject.grades.reduce(0) { $0 + ($1.score * $1.weight) }
        
        let requiredScoreValue = (desiredAverage * (totalCurrentWeight + weight) - totalCurrentScore) / weight
        requiredScore = String(format: "%.2f", requiredScoreValue)
    }
    
    // Hilfsfunktion zur Aktualisierung der Gewichtungen der Abschlussprüfungen
    private func updateFinalExamWeights() {
        let nonFinalGrades = subject.grades.filter { !$0.isFinalExam }
        let totalNonFinalExamWeight = nonFinalGrades.reduce(0) { $0 + $1.weight }
        let finalExamGrades = subject.grades.filter { $0.isFinalExam }
        let totalFinalExamWeight = totalNonFinalExamWeight // Abschlusspruefungen machen die Haelfte des Gesamtgewichts aus
        let individualFinalExamWeight = finalExamGrades.isEmpty ? 0 : totalFinalExamWeight / Double(finalExamGrades.count)
        
        for index in subject.grades.indices {
            if subject.grades[index].isFinalExam {
                subject.grades[index].weight = individualFinalExamWeight
            }
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
