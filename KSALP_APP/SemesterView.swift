//
//  SemesterView.swift
//  KSALP_APP
//
//  Created by Niklas on 29.04.24.
//

import SwiftUI

struct SemesterView: View {
    @StateObject var semesterData = SemesterData() // @StateObject sorgt dafür dass die View auf Änderungen im SemesterData reagiert

    var body: some View {
        NavigationStack {
            List(semesterData.semesters) { semester in// Eine Liste die alle Semester anzeigt. Jedes Semester ist ein klickbarer NavigationLink
                NavigationLink(destination: SubjectAveragesView(semester: semester)) {
                    Text(semester.name)
                }
            }
            .navigationTitle("Semester Übersicht")
        }
        .preferredColorScheme(.light)
    }
}

class SemesterData: ObservableObject {//Class verwaltet die Daten der Semester.
    @Published var semesters: [Semester] = [// @Published ermöglicht es der View auf Änderungen zu reagieren
        Semester(name: "Sommersemester 2024"),
        Semester(name: "Wintersemester 2024"),
        Semester(name: "Sommersemester 2025")
    ]
}

struct SemesterView_Previews: PreviewProvider {
    static var previews: some View {
        SemesterView()
    }
}

class Semester: ObservableObject, Identifiable {//?
    let id = UUID()
    let name: String
    @Published var subjects: [Subject]

    init(name: String, subjects: [Subject] = []) {
        self.name = name
        self.subjects = subjects
    }
}

