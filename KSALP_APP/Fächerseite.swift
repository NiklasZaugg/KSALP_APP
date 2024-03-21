//
//  KSALP_APP
//
//  Created by Niklas on 24.02.24.
//

import SwiftUI

struct Grade {
    var name: String//Name Note
    var score: Double//Wert für Note
    var weight: Double // Gewichtung für die note
}

struct ContentView: View {
    @State private var subjectName: String = "Fach"
    @State private var grades: [Grade] = [
        Grade(name: "", score: 0, weight: 1)
    ]
    
    @State private var average: Double = 0.0
    
    var body: some View {
        VStack {
            // Fachname und Aktionen
            Button(action: {
                // Aktionen hinzufügen (Fach bearbeiten oder löschen)
            }) {
                HStack {
                    Text(subjectName)
                        .font(.title)
                    Image(systemName: "chevron.down")//SFSymbol
                }
                .foregroundColor(.black)
            }
            .padding()
            
            Spacer()

            

            
            HStack(spacing: 0.0){
                Spacer()
                Spacer()
                Spacer()
                Text("Note")
                    .padding(.leading, 85.0)
                Spacer()

                Text("Gewichtung")


            }
            .padding(.top)
            
            // Liste der Noten
            ScrollView {
                VStack {
                    ForEach(grades.indices, id: \.self) { index in
                        HStack {
                            TextField("Prüfung", text: $grades[index].name)
                                .multilineTextAlignment(.center)
                            TextField("Note", text: Binding<String>(
                                get: { String(grades[index].score) },
                                set: { grades[index].score = Double($0) ?? 0.0 }//Dezimal
                            ))
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Gewichtung", text: Binding<String>(
                                get: { String(grades[index].weight) },
                                set: { grades[index].weight = Double($0) ?? 0.0 }//Dezimal
                            ))
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width:60)
                            .opacity(0.5)
                        }
                    }
                }
            }
            .padding()
            .foregroundColor(.black)
            
            // Durchschnittsanzeige
            Text("Durchschnitt: \(String(format: "%.2f", average))")
            
            // Hinzufügen neuer Noten und zum Berechnen des Durchschnitts
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
    
    // Funktion zum Hinzufügen einer neuen Note
    func addGrade() {
        grades.append(Grade(name: "", score: 0, weight: 1))
    }
    
    // Funktion zum Berechnen des Durchschnitts
    func calculateAverage() {
        //filter
        let validGrades = grades.filter { $0.score >= 0 }
        
        // kontrolle
        guard !validGrades.isEmpty else {
            print("Es sind keine gültigen Noten vorhanden.")
            return
        }
        
        let totalScore = validGrades.reduce(0) { $0 + ($1.score * $1.weight) }
        let totalWeight = validGrades.reduce(0) { $0 + $1.weight }
        average = totalScore / totalWeight  //update average
    }
    }
    


    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
