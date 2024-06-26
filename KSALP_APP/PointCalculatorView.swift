import SwiftUI

struct PointCalculatorView: View {
    @State private var inputScore: String = ""
    @State private var maxScore: String = ""
    @State private var calculatedGrade: Double? = nil
    @State private var currentScore: String = ""
    @FocusState private var isMaxScoreFieldFocused: Bool
    @State private var isCurrentScoreCalculated: Bool = false

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
                TextField("Max Punktzahl", text: $maxScore)
                    .keyboardType(.numbersAndPunctuation)
                    .focused($isMaxScoreFieldFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Erreichte Punktzahl:")
                    .padding(.bottom, -10.0)
                TextField("Punktzahl", text: $currentScore)
                    .disabled(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            VStack(spacing: 10) {
                ForEach(0..<3) { row in
                    HStack(spacing: 10) {
                        ForEach(1..<4) { col in
                            let number = row * 3 + col
                            Button(action: {
                                self.inputScore += String(number)
                                self.currentScore += String(number)
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
                        self.inputScore += "0"
                        self.currentScore += "0"
                    }) {
                        Text("0")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        if !self.inputScore.contains(".") {
                            self.inputScore += "."
                            self.currentScore += "."
                        }
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
                        if !self.currentScore.isEmpty {
                            self.currentScore.removeLast()
                            if self.currentScore.isEmpty {
                                self.inputScore = ""
                            } else if self.currentScore.hasSuffix("+") {
                                self.inputScore = ""
                            } else if let lastChar = self.currentScore.last, lastChar.isNumber {
                                self.inputScore = String(lastChar)
                            }
                        }
                    }) {
                        Image(systemName: "delete.left")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color(.systemRed))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        if !self.currentScore.hasSuffix("+") && !self.currentScore.isEmpty && !self.inputScore.isEmpty {
                            self.currentScore += "+"
                            self.inputScore = ""
                        }
                    }) {
                        Text("+")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        self.calculateExpression()
                        self.isCurrentScoreCalculated = true
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: 70)
                            .background(self.canCalculateExpression ? Color(.systemBlue) : Color.gray)
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
        guard let _ = Double(maxScore), isValidNumber(currentScore), isCurrentScoreCalculated else {
            return false
        }
        return true
    }

    private var canCalculateExpression: Bool {
        guard isValidExpression(currentScore) else {
            return false
        }
        return true
    }

    private func isValidNumber(_ number: String) -> Bool {
        let numberPattern = #"^\d+(\.\d+)?$"#
        return number.range(of: numberPattern, options: .regularExpression) != nil
    }

    private func isValidExpression(_ expression: String) -> Bool {
        let expressionPattern = #"^\d+(\.\d+)?([+]\d+(\.\d+)?)*$"#
        return expression.range(of: expressionPattern, options: .regularExpression) != nil
    }

    private func calculateExpression() {
        if currentScore.hasSuffix("+") {
            currentScore.removeLast()
        }

        let expression = NSExpression(format: currentScore)
        if let result = expression.expressionValue(with: nil, context: nil) as? Double {
            self.currentScore = String(format: "%.2f", result)
        } else {
            self.currentScore = "Error"
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
