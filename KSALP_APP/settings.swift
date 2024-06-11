

import SwiftUI

struct Settings: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gefahrenzone").foregroundColor(.red)) {
                    Button(action: {
                        print("Alle Inhalte löschen")
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Alle Inhalte löschen")
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: 44)
                        .background(Color.clear)
                        .cornerRadius(8)
                    }
                }

                Section(header: Text("Probleme oder Fragen?")) {
                    Button(action: {
                        print("Kontaktiere uns")
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text("Kontaktiere uns")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: 44)
                        .background(Color.clear)
                        .cornerRadius(8)
                    }

                    Button(action: {
                        print("Rechtliche Infos")
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Rechtliche Infos")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: 44)
                        .background(Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Einstellungen")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
