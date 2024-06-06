import SwiftUI
import RealmSwift

struct SubjectView: View {
    @ObservedRealmObject var subject: Subject
    @ObservedRealmObject var semester: Semester

    @State private var showActionSheet: Bool = false
    @State private var showingAddGradeSheet: Bool = false
    @State private var showingEditSubjectSheet: Bool = false
    @State private var editingSubjectName: String = ""
    @State private var editingIsMaturarelevant: Bool = false
    @State private var showAdditionalOptions: Bool = false
    @State private var showingAddFinalExamSheet: Bool = false
    @State private var showingCalculatorSheet: Bool = false
    @State private var newName: String = "Neue Note"
    @State private var newScore: String = ""
    @State private var newWeight: String = "1.0"
    @State private var newDate: Date = Date()
    @State private var finalExamName: String = "Abschlussprüfung"
    @State private var finalExamScore: String = ""
    @State private var finalExamDate: Date = Date()
    @State private var desiredGrade: String = ""
    @State private var desiredWeight: String = "1.0"
    @State private var requiredScore: String = ""
    @State private var showingCopySubjectSheet: Bool = false
    @State private var showInfoAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedGrade: Grade?
    @State private var tempGrade: Grade?
    private let realmManager = RealmManager()

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
                .sheet(isPresented: $showingCopySubjectSheet) {
                    CopySubjectSheet(subject: subject)
                }
                .sheet(item: $selectedGrade) { grade in
                    GradeDetailView(
                        grade: Binding(
                            get: { grade },
                            set: { newValue in
                                if let index = subject.grades.firstIndex(where: { $0.id == grade.id }) {
                                    subject.grades[index] = newValue
                                }
                            }
                        )
                    )
                }


            }
            .preferredColorScheme(.light)
            additionalOptionsView
        }
    }
    // Ansicht für Durchschnitt und gerundeten Durchschnitt
    private var averageAndRoundedGradeView: some View {
        HStack(spacing: 20) {
            VStack(spacing: 10) {
                Text("Durchschnitt")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                let averageText = subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade)
                Text(averageText)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
            )
            .shadow(radius: 5)
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Zeugnisnote")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        showInfoAlert = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                    .alert(isPresented: $showInfoAlert) {
                        Alert(
                            title: Text("Info"),
                            message: Text("Die Zeugnisnote in maturarelevanten Fächern wird bei Viertelnoten zugunsten der Abschlussprüfungssumme gerundet."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                
                let roundedText = subject.grades.isEmpty ? "-" : String(format: "%.1f", subject.roundedAverageGrade)
                Text(roundedText)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
            )
            .shadow(radius: 5)
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
            ActionSheet(title: Text("Aktion wählen"), message: nil, buttons: [
                .default(Text("Fach bearbeiten")) {
                    self.editingSubjectName = self.subject.name
                    self.editingIsMaturarelevant = self.subject.isMaturarelevant
                    self.showingEditSubjectSheet = true
                },
                .default(Text("Fach kopieren")) { 
                    self.showingCopySubjectSheet = true
                },
                .destructive(Text("Fach löschen")) {
                    realmManager.deleteSubject(subjectID: subject.id)
                    self.presentationMode.wrappedValue.dismiss()
                },
                .cancel(Text("Abbrechen"))
            ])
        }
    }

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
                            Image("taschenrechner")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
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

    private var addGradeSheet: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Titel", text: $newName)
                }
                .padding(.bottom, 20)
                
                Section {
                    HStack {
                        Text("Datum:")
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
            .navigationBarTitle("Neue Note", displayMode: .inline)
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
                realmManager.updateSubject(
                    subjectID: subject.id,
                    newName: editingSubjectName,
                    isMaturarelevant: editingIsMaturarelevant
                )
                self.showingEditSubjectSheet = false
            })
        }
    }

    private var addFinalExamSheet: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Abschlussprüfung", text: $finalExamName)
                }
                .padding(.bottom, 20)
                
                Section {
                    HStack {
                        Text("Datum:")
                        Spacer()
                        DatePicker("", selection: $finalExamDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
                .padding(.bottom, 20)
                
                Section {
                    HStack {
                        TextField("Note", text: $finalExamScore)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationBarTitle("Neue Abschlussprüfung", displayMode: .inline)
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


    private var calculatorSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Wunschnote eingeben")) {
                    HStack {
                        TextField("Gewünschter Durchschnitt", text: $desiredGrade)
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
                .disabled(desiredGrade.isEmpty)
            )
        }
    }

    private func resetAddGradeFields() {
        newName = "Neue Note"
        newScore = ""
        newWeight = "1.0"
        newDate = Date()
    }

    private func addNewGrade() {
        let scoreValue = Double(newScore) ?? 0
        let weightValue = Double(newWeight) ?? 1.0
        realmManager.addGrade(to: subject.id, name: newName, score: scoreValue, weight: weightValue, date: newDate, isFinalExam: false)
        realmManager.updateFinalExamWeights(for: subject.id)
    }

    private func addNewFinalExam() {
        let scoreValue = Double(finalExamScore) ?? 0
        realmManager.addFinalExam(to: subject.id, name: finalExamName, score: scoreValue, date: finalExamDate)
        realmManager.updateFinalExamWeights(for: subject.id)
    }

    private func resetAddFinalExamFields() {
        finalExamName = "Abschlussprüfung"
        finalExamScore = ""
        finalExamDate = Date()
    }

    private func resetCalculatorFields() {
        desiredGrade = ""
        desiredWeight = "1.0"
        requiredScore = ""
    }

    private func calculateRequiredScore() {
        let desiredAverage = Double(desiredGrade) ?? 0
        let weight = Double(desiredWeight) ?? 1.0
        let totalCurrentWeight = subject.grades.reduce(0) { $0 + $1.weight }
        let totalCurrentScore = subject.grades.reduce(0) { $0 + ($1.score * $1.weight) }

        let requiredScoreValue = (desiredAverage * (totalCurrentWeight + weight) - totalCurrentScore) / weight
        requiredScore = String(format: "%.2f", requiredScoreValue)
    }

    private func updateFinalExamWeights() {
        realmManager.updateFinalExamWeights(for: subject.id)
    }
}

extension Double {
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
