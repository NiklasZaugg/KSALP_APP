import SwiftUI

struct Grade {
    var name: String // Name der Note
    var score: Double // Wert der Note
    var weight: Double // Gewichtung der Note
}

struct ContentView: View {
    @State private var subjectName: String = "Fach"
    @State private var editingSubjectName: String = ""
    @State private var grades: [Grade] = [
        Grade(name: "", score: 0, weight: 1)
    ] {
        didSet {
            calculateAverage()
        }
    }
    
    @State private var average: Double = 0.0
    @State private var showActionSheet: Bool = false


    var body: some View {
        VStack {
            // Fachname und Aktionen
            Button(action: {
                // Zeigt das ActionSheet an
                self.showActionSheet = true
            }) {
                HStack {
                    Text(subjectName)
                        .font(.title)
                    Image(systemName: "chevron.down") // SFSymbol
                }
                .foregroundColor(.black)
            }
            .padding()
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Aktion wählen"), message: nil, buttons: [//2. actionsheet
                    .default(Text("Fachtitel bearbeiten")) {
                        self.editingSubjectName = self.subjectName
                    },
                    .destructive(Text("Fach löschen")) {//rot
                        self.grades.removeAll()
                    },
                    .cancel()
                ])
            }

            Spacer()
            
            HStack{
                Spacer()
                Spacer()
                Text("Note")
                    .padding(.leading, 100.0)
                Spacer()

                Text("Gewichtung")
                    .padding(.trailing, 20.0)
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
                                set: { grades[index].score = Double($0) ?? 0.0 } // Dezimal
                            ))
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            TextField("Gewichtung", text: Binding<String>(
                                get: { String(grades[index].weight) },
                                set: { grades[index].weight = Double($0) ?? 0.0 } // Dezimal
                            ))
                           
                            .padding(.leading, 5)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                            .opacity(0.5)
                            .keyboardType(.decimalPad)
                            

                            Button(action: {
                                // Löschfunktion für die note
                                grades.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)



                                    
                            }
                        }
                    }
                }
            }
            .padding()
            .foregroundColor(.black)
            
            // Durchschnittsanzeige
            Text("Durchschnitt: \(String(format: "%.2f", average))")
            
            // Hinzufügen neuer Noten
            Button(action: addGrade) {
                Text("Neue Note hinzufügen")
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .onAppear(perform: calculateAverage) // Berechnet den Durchschnitt beim ersten Laden
    }
    
    // Funktion zum Hinzufügen einer neuen Note
    func addGrade() {
        grades.append(Grade(name: "", score: 0, weight: 1))
    }
    
    

    
    // Funktion zum Berechnen des Durchschnitts
    func calculateAverage() {
        let validGrades = grades.filter { $0.score >= 0 }
        guard !validGrades.isEmpty else {//kontrolle
            average = 0 // Setzt den Durchschnitt auf 0
            return
        }
        
        let totalScore = validGrades.reduce(0) { $0 + ($1.score * $1.weight) }
        let totalWeight = validGrades.reduce(0) { $0 + $1.weight }
        average = totalScore / totalWeight // Aktualisiert Durchschnitt
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
