import SwiftUI

struct PointCalculatorView: View {
    @State private var inputScore: String = ""
    @State private var maxScore: String = ""
    @State private var calculatedGrade: Double? = nil
    @State private var currentScore: String = ""
    @FocusState private var isMaxScoreFieldFocused: Bool

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 5)
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.15)

                        VStack {
                            Text("Note")
                                .font(.headline)

                            Text(calculatedGrade == nil ? "-" : String(format: "%.2f", calculatedGrade!))
                                .font(.system(size: 64, weight: .bold))
                                .padding()
                        }
                    }

                    Text("Formel: Note = (Punktzahl / Max Punktzahl) * 5 + 1")
                        .font(.caption)
                        .padding(.bottom)

                    VStack(spacing: 16) {
                        Text("Maximalpunktzahl:")
                            .padding(.bottom, -10.0)
                        TextField("Max Punktzahl", text: $maxScore)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: geometry.size.width * 0.5)
                            .focused($isMaxScoreFieldFocused)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Fertig") {
                                        isMaxScoreFieldFocused = false
                                    }
                                }
                            }
                            .padding(.horizontal)

                        Text("Erreichte Punktzahl:")
                            .padding(.bottom, -10.0)
                        TextField("Punktzahl", text: $currentScore)
                            .disabled(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: geometry.size.width * 0.8) 
                            .padding(.horizontal)
                    }

                    HStack(alignment: .top, spacing: 10) {
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
                                                .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                                                .background(Color(.systemTeal))
                                                .foregroundColor(.white)
                                                .cornerRadius(35)
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
                                        .frame(width: geometry.size.width * 0.43, height: geometry.size.height * 0.1)
                                        .background(Color(.systemTeal))
                                        .foregroundColor(.white)
                                        .cornerRadius(35)
                                }

                                Button(action: {
                                    if !self.inputScore.contains(".") {
                                        self.inputScore += "."
                                        self.currentScore += "."
                                    }
                                }) {
                                    Text(".")
                                        .font(.largeTitle)
                                        .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                                        .background(Color(.systemTeal))
                                        .foregroundColor(.white)
                                        .cornerRadius(35)
                                }
                            }
                            .padding(.bottom, 20)
                        }

                        VStack(spacing: 10) {
                            Button(action: {
                                if !self.currentScore.isEmpty {
                                    self.currentScore.removeLast()
                                    if !self.currentScore.hasSuffix("+") {
                                        self.inputScore = ""
                                    }
                                }
                            }) {
                                Image(systemName: "delete.left")
                                    .font(.title)
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                                    .background(Color(.systemRed))
                                    .foregroundColor(.white)
                                    .cornerRadius(35)
                            }

                            Button(action: {
                                if !self.currentScore.hasSuffix("+") {
                                    self.currentScore += "+"
                                    self.inputScore = ""
                                }
                            }) {
                                Text("+")
                                    .font(.title)
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                                    .background(Color(.systemBlue))
                                    .foregroundColor(.white)
                                    .cornerRadius(35)
                            }

                            Button(action: {
                                self.calculateExpression()
                            }) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.title)
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                                    .background(Color(.systemBlue))
                                    .foregroundColor(.white)
                                    .cornerRadius(35)
                            }
                        }
                        .padding(.top, 70.0)
                    }
                    .padding(.top, -5.0)
                    .padding()
                    Spacer()
                    Spacer().frame(height: geometry.size.height * 0.1)
                }
                .preferredColorScheme(.light)
                .padding(.top)
                .navigationBarTitle("PunktRechner", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.calculateGrade()
                        }) {
                            Text("Berechnen")
                                .font(.headline)
                                .foregroundColor(canCalculateGrade ? Color.blue : Color.gray)
                        }
                        .disabled(!canCalculateGrade)
                    }
                }
            }
            .padding(.bottom)
        }
    }

    private var canCalculateGrade: Bool {
        guard let _ = Double(maxScore), !currentScore.isEmpty, let _ = Double(currentScore) else {
            return false
        }
        return true
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

struct PunktRechnerView_Previews: PreviewProvider {
    static var previews: some View {
        PointCalculatorView()
    }
}
