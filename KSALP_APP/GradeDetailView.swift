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
                    }
                    
                    HStack {
                        Text("Gewichtung:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Gewichtung", value: $tempGrade.weight, formatter: NumberFormatter.decimalFormatter)
                    }
                    
                    HStack {
                        Text("Datum:")
                            .frame(width: 140, alignment: .leading)
                        DatePicker("", selection: $tempGrade.date, displayedComponents: .date)
                            .labelsHidden()  // Verbirgt das Label des DatePicker um eine sauberere UI zu gewährleisten
                    }
                }
            }        .navigationBarTitle("Prüfungsdetails", displayMode: .inline)
        .navigationBarItems(
            trailing: Button("Fertig") {
                self.grade = self.tempGrade  // Übertragen der Änderungen auf das Binding-Objekt
                self.presentationMode.wrappedValue.dismiss()
            }
        )
    }
}

extension NumberFormatter {
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}

