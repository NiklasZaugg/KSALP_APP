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
            List($subjects, id: \.name) { $subject in
                NavigationLink(destination: ContentView(subject: $subject)) {
                    HStack {
                        Text(subject.name)
                        Spacer()
                        Text(String(format: "%.2f", subject.averageGrade))
                    }
                }
            }
            .navigationTitle("Fächerdurchschnitte")
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
