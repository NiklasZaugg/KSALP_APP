import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SemesterView()
                .tabItem {
                    Label("Semester", systemImage: "list.bullet")
                }

            PointCalculatorView()
                .tabItem {
                    Label("Notenrechner", systemImage: "rectangle.and.pencil.and.ellipsis")
                }

            ScheduleView()
                .tabItem {
                    Label("Stundenplan", systemImage: "calendar.badge.clock")
                }
            Settings()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
        }
        .accentColor(.black) 
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
