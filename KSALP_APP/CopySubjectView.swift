import SwiftUI
import RealmSwift

struct CopySubjectSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedRealmObject var subject: Subject
    @State private var selectedSemester: Semester?
    private let realmManager = RealmManager()
    
    @ObservedResults(Semester.self) var semesters
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Semester auswählen")) {
                    Picker("Semester", selection: $selectedSemester) {
                        Text("Kein Semester").tag(nil as Semester?)
                        ForEach(semesters, id: \.self) { semester in
                            Text(semester.name).tag(semester as Semester?)
                        }
                    }
                }
            }
            .navigationBarTitle("Fach kopieren", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kopieren") {
                    if let semester = selectedSemester {
                        realmManager.copySubject(subjectID: subject.id, toSemesterID: semester.id)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedSemester == nil)
            )
        }
    }
}
