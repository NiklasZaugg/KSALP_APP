import SwiftUI
import RealmSwift

struct SubjectAveragesView: View {
    @ObservedRealmObject var semester: Semester
    @State private var showingAddSubjectSheet = false
    @State private var newSubjectName = ""
    @State private var isMaturarelevant = false
    @State private var sortOption: SortOption = .nameAscending
    private let realmManager = RealmManager()

    enum SortOption: String, CaseIterable {
        case nameAscending = "Name aufsteigend"
        case nameDescending = "Name absteigend"
        case gradeAscending = "Note aufsteigend"
        case gradeDescending = "Note absteigend"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    HStack(spacing: 5) {
                        // Gesamtschnitt Card
                        summaryCard(
                            title: "Gesamtschnitt",
                            value: overallAverageText,
                            subtext: "Mangelpunkte:",
                            subvalue: overallMinusPointsText,
                            subvalueColor: .red
                        )
                        .frame(maxWidth: .infinity)

                        // Maturaschnitt Card
                        summaryCard(
                            title: "Maturaschnitt",
                            value: maturaAverageText,
                            subtext: "Pluspunkte:",
                            subvalue: maturaPlusPointsText,
                            subvalueColor: .green,
                            subtext2: "Minuspunkte:",
                            subvalue2: maturaMinusPointsText,
                            subvalue2Color: .red
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 130)
                    .frame(width: 371)

                    VStack(spacing: 0) {
                        Divider()
                        
                        HStack {
                            Text("Fächer")
                                .font(.title)
                                .bold()
                                .padding(.top, 4)
                                .padding(.bottom, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Sortier-Button
                            Menu {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        sortOption = option
                                    }) {
                                        Text(option.rawValue)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                                    .padding(.bottom, 4)
                            }
                            
                            Text("\(semester.subjects.count)")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.top, 4)
                                .padding(.bottom, 4)
                                .padding(.trailing, 8)
                        }
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.0))
                                .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                        )

                        Divider()
                    }

                    // Subjects List
                    if semester.subjects.isEmpty {
                        VStack {
                            Spacer()
                            Text("Keine Fächer vorhanden")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top,150)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(sortedSubjects) { subject in
                                NavigationLink(destination: SubjectView(subject: subject, semester: semester)) {
                                    subjectRow(subject: subject)
                                }
                                .listRowInsets(EdgeInsets())
                            }
                        }
                        .padding([.leading, .trailing], 8)
                    }
                }
                .navigationTitle(semester.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fach hinzufügen") {
                            showingAddSubjectSheet = true
                        }
                    }
                }
                .preferredColorScheme(.light)
                .padding()
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
            .sheet(isPresented: $showingAddSubjectSheet) {
                NavigationStack {
                    Form {
                        TextField("Fachname", text: $newSubjectName)
                        Toggle("Maturarelevant", isOn: $isMaturarelevant)
                    }
                    .navigationTitle("Neues Fach")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                showingAddSubjectSheet = false
                                newSubjectName = ""
                                isMaturarelevant = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Hinzufügen") {
                                addNewSubject()
                            }
                            .disabled(newSubjectName.isEmpty)
                        }
                    }
                }
            }
        }
    }

    // Computed property to sort subjects based on the selected sort option
    private var sortedSubjects: [Subject] {
        switch sortOption {
        case .nameAscending:
            return semester.subjects.sorted { $0.name < $1.name }
        case .nameDescending:
            return semester.subjects.sorted { $0.name > $1.name }
        case .gradeAscending:
            return semester.subjects.sorted { $0.averageGrade < $1.averageGrade }
        case .gradeDescending:
            return semester.subjects.sorted { $0.averageGrade > $1.averageGrade }
        }
    }

    private func summaryCard(title: String, value: String, subtext: String, subvalue: String, subvalueColor: Color, subtext2: String? = nil, subvalue2: String? = nil, subvalue2Color: Color? = nil) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Text(value)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text(subtext)
                        .font(.caption)
                        .foregroundColor(subvalueColor)
                    Text(subvalue)
                        .font(.caption)
                        .foregroundColor(subvalueColor)
                }
                if let subtext2 = subtext2, let subvalue2 = subvalue2, let subvalue2Color = subvalue2Color {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(subtext2)
                            .font(.caption)
                            .foregroundColor(subvalue2Color)
                        Text(subvalue2)
                            .font(.caption)
                            .foregroundColor(subvalue2Color)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1.5)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }

    private func subjectRow(subject: Subject) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(subject.name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if subject.isMaturarelevant {
                    Text("Matura")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
            Spacer()
            Text(subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade))
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.4), Color.blue.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black, lineWidth: 1.5)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        .padding([.leading, .trailing], 6)
    }

    private func addNewSubject() {
        realmManager.addSubject(to: semester.id, name: newSubjectName, isMaturarelevant: isMaturarelevant)
        showingAddSubjectSheet = false
        newSubjectName = ""
        isMaturarelevant = false
    }

    var overallAverage: Double {
        let subjectsWithGrades = semester.subjects.filter { !$0.grades.isEmpty }
        let weightedAverages = subjectsWithGrades.map { $0.averageGrade }
        let sum = weightedAverages.reduce(0, +)
        return !weightedAverages.isEmpty ? sum / Double(weightedAverages.count) : 0
    }

    var overallAverageText: String {
        return overallAverage == 0 && semester.subjects.allSatisfy { $0.grades.isEmpty } ? "-" : String(format: "%.2f", overallAverage)
    }

    var maturaAverage: Double {
        let maturaSubjects = semester.subjects.filter { $0.isMaturarelevant && !$0.grades.isEmpty }
        let weightedAverages = maturaSubjects.map { $0.averageGrade }
        let sum = weightedAverages.reduce(0, +)
        return !weightedAverages.isEmpty ? sum / Double(weightedAverages.count) : 0
    }

    var maturaAverageText: String {
        return maturaAverage == 0 ? "-" : String(format: "%.2f", maturaAverage)
    }

    func roundedToNearestHalf(_ value: Double) -> Double {
        return (value * 2).rounded() / 2
    }

    var overallMinusPoints: Double {
        let allSubjects = semester.subjects.filter { !$0.grades.isEmpty }
        let minusPoints = allSubjects.map { max(4 - roundedToNearestHalf($0.roundedAverageGrade), 0) }
        return minusPoints.reduce(0, +)
    }

    var maturaPlusPoints: Double {
        let maturaSubjects = semester.subjects.filter { $0.isMaturarelevant && !$0.grades.isEmpty }
        let plusPoints = maturaSubjects.map { max(roundedToNearestHalf($0.roundedAverageGrade) - 4, 0) }
        return plusPoints.reduce(0, +)
    }

    var maturaMinusPoints: Double {
        let maturaSubjects = semester.subjects.filter { $0.isMaturarelevant && !$0.grades.isEmpty }
        let minusPoints = maturaSubjects.map { max(4 - roundedToNearestHalf($0.roundedAverageGrade), 0) }
        return minusPoints.reduce(0, +)
    }
    
    var maturaPlusPointsText: String {
        return maturaAverage == 0 ? "-" : String(format: "+%.1f", maturaPlusPoints)
    }

    var maturaMinusPointsText: String {
        return maturaAverage == 0 ? "-" : String(format: "-%.1f", maturaMinusPoints)
    }

    var overallMinusPointsText: String {
        return overallAverage == 0 ? "-" : String(format: "%.1f", overallMinusPoints)
    }
}

struct SubjectAveragesView_Previews: PreviewProvider {
    static var previews: some View {
        let semester = Semester()
        semester.name = "Semester 1"
        semester.subjects.append(Subject(value: ["name": "Mathematik", "isMaturarelevant": true]))
        semester.subjects.append(Subject(value: ["name": "Biologie", "isMaturarelevant": false]))

        return SubjectAveragesView(semester: semester)
            .preferredColorScheme(.light)
    }
}
