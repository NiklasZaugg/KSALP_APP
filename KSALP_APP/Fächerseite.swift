//
//  KSALP_APP
//
//  Created by Niklas on 24.02.24.
//

import SwiftUI

struct Grade {
    var name: String
    var score: Double
}

struct ContentView: View {
    @State private var subjectName: String = "Fach"
    @State private var grades: [Grade] = [
        Grade(name: "", score: 0)
    ]
    
    @State private var average: Double = 0.0//var wird auf 0.0 definiert
    
    var body: some View {
        VStack {
            TextField("Fach", text: $subjectName)
                .padding()
            
            ScrollView {
                VStack {
                    ForEach(grades.indices, id: \.self) { index in
                        HStack {
                            TextField("Prüfung", text: $grades[index].name)
                            TextField("Note", value: $grades[index].score, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .foregroundColor(.black)
            
        
            
            Text("Durchschnitt: \(average)")
            
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
        average = totalScore / Double(validGrades.count) // Update average
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
