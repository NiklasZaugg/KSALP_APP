import SwiftUI
import RealmSwift

struct SemesterView: View {
    @ObservedResults(Semester.self) var semesters
    @State private var showingAddSemester = false
    @State private var newSemesterName = ""
    @State private var isEditing = false
    @State private var selectedSemester: Semester?
    @State private var editedSemesterName = ""
    @State private var showingDeleteConfirmation = false
    @State private var semesterToDelete: Semester?
    private let realmManager = RealmManager()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    if semesters.isEmpty {
                        VStack {
                            Spacer()
                            Text("Keine Semester vorhanden")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top, 200)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(semesters) { semester in
                                ZStack(alignment: .topLeading) {
                                    if isEditing {
                                        HStack {
                                            Button(action: {
                                                withAnimation {
                                                    semesterToDelete = semester
                                                    showingDeleteConfirmation = true
                                                }
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 3)
                                                    .padding(5)
                                            }
                                            Button(action: {
                                                self.selectedSemester = semester
                                                self.editedSemesterName = semester.name
                                            }) {
                                                Image(systemName: "pencil.circle.fill")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.blue)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 3)
                                                    .padding(5)
                                            }
                                        }
                                        .offset(x: -10, y: -10)
                                        .zIndex(1)
                                    }
                                    NavigationLink(destination: SubjectAveragesView(semester: semester)) {
                                        Text(semester.name)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity, minHeight: 100)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                            .background(Color.blue) // Semester background remains blue
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(isEditing)
                                }
                            }
                        }
                        .padding()
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showingAddSemester = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.0, green: 0.6, blue: 1, opacity: 0.9))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Semester Übersicht")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Fertig" : "Bearbeiten")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAddSemester) {
                NavigationStack {
                    Form {
                        TextField("Semestername", text: $newSemesterName)
                    }
                    .navigationTitle("Neues Semester")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                showingAddSemester = false
                                newSemesterName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Fertig") {
                                if !newSemesterName.isEmpty {
                                    addSemester(name: newSemesterName)
                                    newSemesterName = ""
                                    showingAddSemester = false
                                }
                            }
                            .disabled(newSemesterName.isEmpty)
                        }
                    }
                }
            }

            .sheet(item: $selectedSemester) { semester in
                NavigationStack {
                    Form {
                        TextField("Semestername bearbeiten", text: $editedSemesterName)
                    }
                    .navigationTitle("Semester bearbeiten")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                self.isEditing = false
                                selectedSemester = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Fertig") {
                                if !editedSemesterName.isEmpty, let selectedSemester = selectedSemester {
                                    updateSemesterName(semester: selectedSemester, newName: editedSemesterName)
                                }
                                self.isEditing = false
                                self.selectedSemester = nil
                            }
                            .disabled(editedSemesterName.isEmpty)
                        }
                    }
                }
            }

            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Semester löschen"),
                    message: Text("Möchten Sie dieses Semester wirklich löschen?"),
                    primaryButton: .destructive(Text("Löschen")) {
                        if let semester = semesterToDelete {
                            deleteSemester(semester.id)
                        }
                        showingDeleteConfirmation = false
                    },
                    secondaryButton: .cancel(Text("Abbrechen")) {
                        showingDeleteConfirmation = false
                    }
                )
            }
        }
        .preferredColorScheme(.light)
    }

    private func addSemester(name: String) {
        realmManager.addSemester(name: name)
    }

    private func deleteSemester(_ semesterID: String) {
        realmManager.removeSemester(semesterID: semesterID)
    }

    private func updateSemesterName(semester: Semester, newName: String) {
        realmManager.updateSemesterName(semesterID: semester.id, newName: newName)
    }
}

struct SemesterView_Previews: PreviewProvider {
    static var previews: some View {
        SemesterView()
    }
}
