import RealmSwift
import SwiftUI

struct Settings: View {
    @State private var showAlert = false
    private let realmManager = RealmManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gefahrenzone").foregroundColor(.red)) {
                    Button(action: {
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Alle Semester löschen")
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: 44)
                        .background(Color.clear)
                        .cornerRadius(8)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Alle Semester löschen"),
                            message: Text("Bist du sicher, dass du alle Semester löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden."),
                            primaryButton: .destructive(Text("Löschen")) {
                                realmManager.deleteAllContents()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section(header: Text("Probleme oder Fragen?")) {
                    Link(destination: URL(string: "https://www.gradeez.ch/contact-8")!) {
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
                    
                    Link(destination: URL(string: "https://www.gradeez.ch/privacy-policy")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Rechtliche Infos")
                                .foregroundColor(.blue)
                                .padding(.leading, 7)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: 44)
                        .background(Color.clear)
                        .cornerRadius(8)
                    }
                }
                
                Section {
                    Text("Copyright © 2024 Niklas Zaugg. Version 1.1")
                        .font(.caption)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
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
