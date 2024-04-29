//
//  SubjectAveragesView.swift
//  KSALP_APP
//
//  Created by Niklas on 24.04.24.
//

import SwiftUI

struct SubjectAveragesView: View {
    @State var subjects: [Subject] = [
        Subject(name: "Mathematik"),
        Subject(name: "Englisch"),
        Subject(name: "Biologie")
    ]

    var body: some View {
        NavigationStack {
            List($subjects, id: \.id) { $subject in  // Verwendung der .id Property für eindeutige Identifikation
                NavigationLink(destination: ContentView(subject: $subject)) {
                    HStack {
                        Text(subject.name)
                        Spacer()
                        Text(String(format: "%.2f", subject.averageGrade))
                    }
                }
            }
            .navigationTitle("Fächerdurchschnitte")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fach hinzufügen") {
                        let newSubject = Subject(name: "Neues Fach")
                        subjects.append(newSubject)
                    }
                }
            }
            .preferredColorScheme(.light)
        }
    }
}



// Preview der neuen View
struct SubjectAveragesView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectAveragesView()
    }
}
