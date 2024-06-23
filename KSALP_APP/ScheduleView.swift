import SwiftUI
import PDFKit

struct ScheduleView: View {
    let classes = [
        "U23a", "U23b", "U23c", "U23d", "U23e", "U23f", "U23g", "U23h", "U23i", "U23k", "U23l", "U23m", "U23n",
        "U22a", "U22b", "U22c", "U22d", "U22e", "U22f", "U22g", "U22h", "U22i", "U22k", "U22l", "U22m", "U22n",
        "G23a", "G23b", "G23c", "G23d", "G23e", "G23f", "G23g", "G23h", "G23i", "G23k", "G23l", "G23m", "G23n",
        "T23a", "T23b",
        "G22a", "G22b", "G22c", "G22d", "G22e", "G22f", "G22g", "G22h", "G22i", "G22k", "G22l", "G22m",
        "T22a", "T22b",
        "G21a", "G21b", "G21c", "G21d", "G21e", "G21f", "G21g", "G21h", "G21i", "G21k", "G21l", "G21m", "G21n",
        "T21a", "T21b",
        "G20a", "G20b", "G20c", "G20d", "G20e", "G20f", "G20g", "G20h", "G20i", "G20k", "G20l",
        "T20a", "T20b",
        "T19a", "T19b"
    ]
    
    @State private var selectedClass: String? = nil
    @State private var favoriteClasses: Set<String> = UserDefaults.standard.stringArray(forKey: "favoriteClasses")?.reduce(into: Set<String>()) { $0.insert($1) } ?? []

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sortedClasses, id: \.self) { className in
                            FavoriteClassButton(className: className, isFavorite: favoriteClasses.contains(className), isSelected: className == selectedClass) {
                                toggleFavorite(className: className)
                            } onSelect: {
                                selectedClass = className
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
                if let selectedClass = selectedClass {
                    TimetableView(className: selectedClass)
                }
            }
            .navigationTitle("Stundenplan")
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
    
    private var sortedClasses: [String] {
        let favoriteClassesArray = Array(favoriteClasses)
        let nonFavoriteClasses = classes.filter { !favoriteClasses.contains($0) }
        return favoriteClassesArray + nonFavoriteClasses
    }

    private func toggleFavorite(className: String) {
        if favoriteClasses.contains(className) {
            favoriteClasses.remove(className)
        } else {
            favoriteClasses.insert(className)
        }
        UserDefaults.standard.set(Array(favoriteClasses), forKey: "favoriteClasses")
    }
}

struct FavoriteClassButton: View {
    let className: String
    let isFavorite: Bool
    let isSelected: Bool
    var onFavoriteToggle: () -> Void
    var onSelect: () -> Void

    var body: some View {
        Button(action: {
            onSelect()
        }) {
            HStack {
                Text(className)
                    .padding(.leading, 10)
                    .padding(.vertical, 10)
                    .foregroundColor(isSelected ? .white : .black)
                Spacer()
                Button(action: {
                    onFavoriteToggle()
                }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .gray)
                        .padding(.trailing, 10)
                }
            }
            .padding(5)
            .background(isSelected ? Color.blue : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TimetableView: View {
    let className: String
    
    var body: some View {
        PDFViewer(pdfName: "\(className).pdf")
            .padding()
            .background(Color.white)
    }
}

struct PDFViewer: UIViewRepresentable {
    let pdfName: String
    let fixedScaleFactor: CGFloat = 0.55

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = false
        pdfView.scaleFactor = fixedScaleFactor
        pdfView.displayDirection = .vertical
        pdfView.displayMode = .singlePageContinuous

        if let path = Bundle.main.url(forResource: pdfName, withExtension: nil, subdirectory: "Klassen_23_24") {
            if let document = PDFDocument(url: path) {
                pdfView.document = document
            }
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if let path = Bundle.main.url(forResource: pdfName, withExtension: nil, subdirectory: "Klassen_23_24") {
            if let document = PDFDocument(url: path) {
                uiView.document = document
                uiView.scaleFactor = fixedScaleFactor 
            }
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
