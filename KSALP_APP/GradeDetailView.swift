import SwiftUI
import RealmSwift

struct GradeDetailView: View {
    @Binding var grade: Grade
    @Environment(\.presentationMode) var presentationMode

    @State private var tempName: String
    @State private var tempScore: String
    @State private var tempWeight: String
    @State private var tempDate: Date

    init(grade: Binding<Grade>) {
        self._grade = grade
        self._tempName = State(initialValue: grade.wrappedValue.name)
        self._tempScore = State(initialValue: "\(grade.wrappedValue.score)")
        self._tempWeight = State(initialValue: "\(grade.wrappedValue.weight)")
        self._tempDate = State(initialValue: grade.wrappedValue.date)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Titel:")
                        Spacer()
                        TextField("Titel", text: $tempName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.bottom, 20)

                Section {
                    HStack {
                        Text("Datum der Prüfung:")
                        Spacer()
                        DatePicker("", selection: $tempDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
                .padding(.bottom, 20)

                Section {
                    HStack {
                        Text("Note:")
                        Spacer()
                        TextField("Note", text: $tempScore)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Gewichtung:")
                        Spacer()
                        TextField("Gewichtung", text: $tempWeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    Button(action: {
                        deleteGrade()
                    }) {
                        HStack {
                            Spacer()
                            Text("Note Löschen")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitle("Notendetails", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Speichern") {
                    saveGradeDetails()
                }
            )
        }
    }

    private func saveGradeDetails() {
        do {
            let realm = try Realm()
            try realm.write {
                if let gradeToUpdate = realm.object(ofType: Grade.self, forPrimaryKey: grade.id) {
                    gradeToUpdate.name = tempName
                    gradeToUpdate.score = Double(tempScore) ?? 0.0
                    gradeToUpdate.weight = Double(tempWeight) ?? 1.0
                    gradeToUpdate.date = tempDate
                }
            }
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Fehler beim Speichern der Notendetails: \(error.localizedDescription)")
        }
    }

    private func deleteGrade() {
        do {
            let realm = try Realm()
            try realm.write {
                if let gradeToDelete = realm.object(ofType: Grade.self, forPrimaryKey: grade.id) {
                    realm.delete(gradeToDelete)
                }
            }
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Fehler beim Löschen der Note: \(error.localizedDescription)")
        }
    }
}
