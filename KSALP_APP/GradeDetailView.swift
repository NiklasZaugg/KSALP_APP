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
        NavigationStack {
            Form {
                Section(header: Text("Details").font(.headline)) {
                    HStack {
                        Text("Prüfung:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Prüfung", text: $tempGrade.name)
                    }
                    
                    HStack {
                        Text("Note:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Note", value: $tempGrade.score, formatter: NumberFormatter.decimalFormatter)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Gewichtung:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Gewichtung", value: $tempGrade.weight, formatter: NumberFormatter.decimalFormatter)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Datum:")
                            .frame(width: 140, alignment: .leading)
                        DatePicker("", selection: $tempGrade.date, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }
            .navigationBarTitle("Prüfungsdetails", displayMode: .inline)
            .navigationBarItems(trailing: Button("Fertig") {
                self.grade = self.tempGrade
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

extension NumberFormatter {
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1 // Stellt sicher  dass mindestens eine Dezimalstelle angezeigt wird
        formatter.maximumFractionDigits = 5 // Erlaubt bis zu fünf Dezimalstellen
        formatter.alwaysShowsDecimalSeparator = true // Zeigt immer einen Dezimaltrenner an
        return formatter
    }()
}
