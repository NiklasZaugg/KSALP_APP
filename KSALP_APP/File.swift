//
//  File.swift
//  KSALP_APP
//
//  Created by Niklas on 21.03.24.
//

import SwiftUI

struct Grade {
    var name: String
    var score: Double
}

struct ContentView: View {
    @State private var subjectName: String = ""
    @State private var grades: [Grade] = [
        Grade(name: "test", score: 0),

    ]
    
    var body: some View {
        VStack {
            TextField("Fach", text: $subjectName)
                .padding()
            
            List {
                ForEach(grades.indices, id: \.self) { index in
                    HStack {
                        TextField("Name", text: $grades[index].name)
                        TextField("Note", value: $grades[index].score, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding()
            
            Button(action: addGrade) {
                Text("Neue Note hinzufügen")
            }
            .padding()
            
            Button(action: calculateAverage) {
                Text("Durchschnitt berechnen")
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func addGrade() {
        grades.append(Grade(name: "", score: 0))
    }
    
    func calculateAverage() {
        let validGrades = grades.filter { $0.score >= 0 }
        guard !validGrades.isEmpty else {
            print("Es sind keine gültigen Noten vorhanden.")
            return
        }
        
        let totalScore = validGrades.reduce(0) { $0 + $1.score }
        let average = totalScore / Double(validGrades.count)
        
        print("Der Durchschnitt für \(subjectName) beträgt: \(average)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

