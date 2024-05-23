//
//  GradeDetailView.swift
//  KSALP_APP
//
//  Created by Niklas on 20.04.24.
//

import SwiftUI

struct GradeDetailView: View {
    @Binding var grade: Grade
    @Environment(\.presentationMode) var presentationMode
    
    // Temporäre lokale Kopie für die Bearbeitung in der Detailansicht
    @State private var tempGrade: Grade

    // Initialisierung der lokalen Kopie im Konstruktor
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

struct GradeDetailView_Previews: PreviewProvider {
    @State static var grade = Grade(name: "Test", score: 1.0, weight: 1.0, date: Date(), isFinalExam: false)
    
    static var previews: some View {
        GradeDetailView(grade: $grade)
    }
}
