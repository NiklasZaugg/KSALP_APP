import SwiftUI
import RealmSwift

struct SubjectAveragesView: View {
    @ObservedRealmObject var semester: Semester
    @State private var showingAddSubjectSheet = false
    @State private var newSubjectName = ""
    @State private var isMaturarelevant = false
    private let realmManager = RealmManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 4) {
                    HStack {
                        VStack {
                            Text("Gesamtschnitt ")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(overallAverageText)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                            Spacer()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Mangelpunkte:")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text("\(overallMinusPointsText)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1.5)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

                        VStack {
                            Text("Maturaschnitt")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(maturaAverageText)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                            Spacer()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Pluspunkte:")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Text("\(maturaPlusPointsText)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                VStack(alignment: .leading) {
                                    Text("Minuspunkte:")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text("\(maturaMinusPointsText)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1.5)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

                    }
                    .frame(height: 130)

                    HStack {
                        Text("Fächer")
                            .font(.title)
                            .bold()
                            .padding(.top, 4)
                            .padding(.bottom, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(semester.subjects.count)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                            .padding(.bottom, 4)
                            .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 8)
                    .background(Color.white)
                    .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)

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
                        VStack(spacing: 0) {
                            ForEach(semester.subjects) { subject in
                                NavigationLink(destination: SubjectView(subject: subject, semester: semester)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(subject.name)
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            if subject.isMaturarelevant {
                                                Text("Matura")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            } else {
                                                Text("")
                                                    .font(.caption)
                                                    .foregroundColor(.clear)
                                            }
                                        }
                                        Spacer()
                                        Text(subject.grades.isEmpty ? "-" : String(format: "%.2f", subject.averageGrade))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                    .shadow(color: Color.gray.opacity(0.3), radius: 3, x: 0, y: 2)
                                    .padding([.leading, .trailing], 4)
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
            }
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
