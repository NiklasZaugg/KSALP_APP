import SwiftUI

struct PointCalculatorView: View {
    @State private var maxScore: String = ""
    @State private var currentScore: String = ""
    @State private var calculatedGrade: Double? = nil
    @State private var isCurrentScoreCalculated: Bool = false
    @State private var activeField: ActiveField? = nil 

    enum ActiveField {
        case maxScore, currentScore
    }

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 5)

                VStack {
                    Spacer()
                    Text("Note")
                        .font(.headline)
                    Text(calculatedGrade == nil ? "-" : String(format: "%.2f", calculatedGrade!))
                        .font(.system(size: 48, weight: .bold))
                        .padding()
                    Spacer()
                    Text("Formel: Note = (Punktzahl / Max Punktzahl) * 5 + 1")
                        .font(.caption)
                        .padding(.vertical, 5.0)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                Button(action: {
                    calculateGrade()
                }) {
                    Text("Berechnen")
                        .foregroundColor(canCalculateGrade ? .blue : .gray)
                        .padding()
                }
                .padding([.top, .trailing], 1)
                .disabled(!canCalculateGrade)
            }
            
            Spacer()

            VStack(spacing: 16) {
                Text("Maximalpunktzahl:")
                    .padding(.bottom, -10.0)
                Button(action: {
                    activeField = .maxScore
                }) {
                    Text(maxScore.isEmpty ? "-" : maxScore)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(activeField == .maxScore ? Color.blue.opacity(0.2) : Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(activeField == .maxScore ? Color.blue : Color.gray, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal)

                Text("Erreichte Punktzahl:")
                    .padding(.bottom, -10.0)
                Button(action: {
                    activeField = .currentScore
                }) {
                    Text(currentScore.isEmpty ? "-" : currentScore)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(activeField == .currentScore ? Color.blue.opacity(0.2) : Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(activeField == .currentScore ? Color.blue : Color.gray, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal)
            }

            VStack(spacing: 10) {
                ForEach(0..<3) { row in
                    HStack(spacing: 10) {
                        ForEach(1..<4) { col in
                            let number = row * 3 + col
                            Button(action: {
                                addCharacterToActiveField(String(number))
                            }) {
                                Text("\(number)")
                                    .font(.largeTitle)
                                    .frame(maxWidth: .infinity, maxHeight: 70)
                                    .background(Color.blue.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    Button(action: {
                        addCharacterToActiveField("0")
                    }) {
                        Text("0")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        addCharacterToActiveField(".")
                    }) {
                        Text(".")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)

                HStack(spacing: 10) {
                    Button(action: {
                        removeLastCharacterFromActiveField()
                    }) {
                        Image(systemName: "delete.left")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color(.systemRed))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        addCharacterToActiveField("+")
                    }) {
                        Text("+")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        calculateExpressionForActiveField()
                        isCurrentScoreCalculated = true
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(canCalculateExpression ? Color(.systemBlue) : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!canCalculateExpression)
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
    }

    private var canCalculateGrade: Bool {
        guard let _ = Double(maxScore), isValidExpression(currentScore), isCurrentScoreCalculated else {
            return false
        }
        return true
    }

    private var canCalculateExpression: Bool {
        guard let fieldValue = getActiveFieldValue(), isValidExpression(fieldValue) else {
            return false
        }
        return true
    }

    private func isValidExpression(_ expression: String) -> Bool {
        let expressionPattern = #"^\d+(\.\d+)?([+]\d+(\.\d+)?)*$"#
        return expression.range(of: expressionPattern, options: .regularExpression) != nil
    }

    private func calculateExpressionForActiveField() {
        guard let expression = getActiveFieldValue(), !expression.hasSuffix("+") else { return }

        let nsExpression = NSExpression(format: expression)
        if let result = nsExpression.expressionValue(with: nil, context: nil) as? Double {
            let formattedResult = String(format: "%.2f", result)
            setActiveFieldValue(formattedResult)
        } else {
            setActiveFieldValue("Error")
        }
    }

    private func calculateGrade() {
        guard let score = Double(currentScore), let maxScore = Double(maxScore), maxScore > 0 else {
            self.calculatedGrade = nil
            return
        }
        let percentage = score / maxScore
        self.calculatedGrade = percentage * 5 + 1
    }

    private func addCharacterToActiveField(_ character: String) {
        guard var fieldValue = getActiveFieldValue() else { return }
        
        if character == "." {
            let components = fieldValue.split(separator: "+")
            if let lastComponent = components.last, lastComponent.contains(".") {
                return
            }
        }

        if character == "+" && (fieldValue.isEmpty || fieldValue.hasSuffix("+")) {
            return
        }
        
        fieldValue += character
        setActiveFieldValue(fieldValue)
    }

    private func removeLastCharacterFromActiveField() {
        guard var fieldValue = getActiveFieldValue(), !fieldValue.isEmpty else { return }
        fieldValue.removeLast()
        setActiveFieldValue(fieldValue)
    }

    private func getActiveFieldValue() -> String? {
        switch activeField {
        case .maxScore:
            return maxScore
        case .currentScore:
            return currentScore
        case .none:
            return nil
        }
    }

    private func setActiveFieldValue(_ value: String) {
        switch activeField {
        case .maxScore:
            maxScore = value
        case .currentScore:
            currentScore = value
        case .none:
            break
        }
    }
}

struct TabbedView: View {
    var body: some View {
        NavigationView {
            TabView {
                PointCalculatorView()
                    .tabItem {
                        Image(systemName: "1.circle")
                        Text("Calculator")
                    }
                Text("Another View")
                    .tabItem {
                        Image(systemName: "2.circle")
                        Text("Another Tab")
                    }
            }
        }
    }
}

struct PunktRechnerView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView()
    }
}
