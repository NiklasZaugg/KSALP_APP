import RealmSwift
import Foundation

class Grade: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var score = 0.0
    @objc dynamic var weight = 1.0
    @objc dynamic var date = Date()
    @objc dynamic var isFinalExam = false

    override static func primaryKey() -> String? {
        return "id"
    }
}

class Subject: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    let grades = List<Grade>()
    @objc dynamic var isMaturarelevant = false

    override static func primaryKey() -> String? {
        return "id"
    }

    var averageGrade: Double {
        let totalWeight = grades.reduce(0) { $0 + $1.weight }
        let totalScore = grades.reduce(0) { $0 + ($1.score * $1.weight) }
        return totalWeight == 0 ? 0 : totalScore / totalWeight
    }

    var roundedAverageGrade: Double {
        let average = averageGrade
        let adjustedAverage: Double

        if isMaturarelevant, let finalExam = grades.first(where: { $0.isFinalExam }) {
            let adjustedTotalWeight = grades.reduce(0) { $0 + $1.weight } + 0.01
            let adjustedTotalScore = grades.reduce(0) { $0 + ($1.score * $1.weight) } + (finalExam.score * 0.01)
            adjustedAverage = adjustedTotalWeight == 0 ? 0 : adjustedTotalScore / adjustedTotalWeight
        } else {
            adjustedAverage = average
        }

        let rounded = (adjustedAverage * 2).rounded() / 2
        return rounded
    }
}

class Semester: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    let subjects = List<Subject>()

    override static func primaryKey() -> String? {
        return "id"
    }
}
