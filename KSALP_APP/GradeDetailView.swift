import SwiftUI

struct GradeDetailView: View {
    @Binding var grade: Grade
    @Environment(\.presentationMode) var presentationMode

    @State private var tempGrade: Grade

    init(grade: Binding<Grade>) {
        self._grade = grade
        self._tempGrade = State(initialValue: grade.wrappedValue)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details").font(.headline)) {
                    HStack {
                        Text("Titel:")
                        Spacer()
                        TextField("Titel", text: $tempGrade.name)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Datum der Prüfung:")
                        Spacer()
                        DatePicker("", selection: $tempGrade.date, displayedComponents: .date)
                            .labelsHidden()
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Note:")
                        Spacer()
                        TextField("Note", value: $tempGrade.score, formatter: NumberFormatter.decimalFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Gewichtung:")
                        Spacer()
                        TextField("Gewichtung", value: $tempGrade.weight, formatter: NumberFormatter.decimalFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationBarTitle("Notendetails", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Speichern") {
                    grade = tempGrade
                    let realmManager = RealmManager()
                    realmManager.updateGrade(
                        gradeID: grade.id,
                        name: grade.name,
                        score: grade.score,
                        weight: grade.weight,
                        date: grade.date
                    )
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

extension NumberFormatter {
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
