import RealmSwift
import Foundation

class RealmManager {
    private var realm: Realm

    init() {
        do {
            realm = try Realm()
        } catch let error as NSError {
            fatalError("Fehler beim Öffnen von Realm: \(error.localizedDescription)")
        }
    }

    func addSemester(name: String) {
        let semester = Semester()
        semester.name = name

        do {
            try realm.write {
                realm.add(semester)
            }
        } catch let error as NSError {
            print("Fehler beim Hinzufügen des Semesters: \(error.localizedDescription)")
        }
    }

    func updateSemesterName(semesterID: String, newName: String) {
        do {
            if let semester = realm.object(ofType: Semester.self, forPrimaryKey: semesterID) {
                try realm.write {
                    semester.name = newName
                }
            }
        } catch let error as NSError {
            print("Fehler beim Aktualisieren des Semesternamens: \(error.localizedDescription)")
        }
    }

    func removeSemester(semesterID: String) {
        do {
            if let semester = realm.object(ofType: Semester.self, forPrimaryKey: semesterID) {
                try realm.write {
                    realm.delete(semester)
                }
            }
        } catch let error as NSError {
            print("Fehler beim Entfernen des Semesters: \(error.localizedDescription)")
        }
    }

    func addSubject(to semesterID: String, name: String, isMaturarelevant: Bool) {
        do {
            try realm.write {
                if let semester = realm.object(ofType: Semester.self, forPrimaryKey: semesterID) {
                    let subject = Subject()
                    subject.name = name
                    subject.isMaturarelevant = isMaturarelevant
                    semester.subjects.append(subject)
                }
            }
        } catch let error as NSError {
            print("Fehler beim Hinzufügen des Fachs: \(error.localizedDescription)")
        }
    }

    func addGrade(to subjectID: String, name: String, score: Double, weight: Double, date: Date, isFinalExam: Bool) {
        do {
            try realm.write {
                if let subject = realm.object(ofType: Subject.self, forPrimaryKey: subjectID) {
                    let grade = Grade()
                    grade.name = name
                    grade.score = score
                    grade.weight = weight
                    grade.date = date
                    grade.isFinalExam = isFinalExam
                    subject.grades.append(grade)
                }
            }
        } catch let error as NSError {
            print("Fehler beim Hinzufügen der Note: \(error.localizedDescription)")
        }
    }

    func updateGradeName(gradeID: String, newName: String) throws {
        do {
            if let grade = realm.object(ofType: Grade.self, forPrimaryKey: gradeID) {
                try realm.write {
                    grade.name = newName
                }
            }
        } catch let error as NSError {
            throw error
        }
    }

    func updateGrade(gradeID: String, name: String, score: Double, weight: Double, date: Date) {
        do {
            if let grade = realm.object(ofType: Grade.self, forPrimaryKey: gradeID) {
                try realm.write {
                    grade.name = name
                    grade.score = score
                    grade.weight = weight
                    grade.date = date
                }
            }
        } catch let error as NSError {
            print("Fehler beim Aktualisieren der Note: \(error.localizedDescription)")
        }
    }

    func updateGradeDetails(gradeID: String, newName: String, newScore: Double, newWeight: Double, newDate: Date) throws {
        do {
            if let grade = realm.object(ofType: Grade.self, forPrimaryKey: gradeID) {
                try realm.write {
                    grade.name = newName
                    grade.score = newScore
                    grade.weight = newWeight
                    grade.date = newDate
                }
            }
        } catch let error as NSError {
            throw error
        }
    }

    func addFinalExam(to subjectID: String, name: String, score: Double, date: Date) {
        do {
            if let subject = realm.object(ofType: Subject.self, forPrimaryKey: subjectID) {
                let nonFinalGrades = subject.grades.filter { !$0.isFinalExam }
                let totalNonFinalExamWeight = nonFinalGrades.reduce(0) { $0 + $1.weight }
                let finalExamGrades = subject.grades.filter { $0.isFinalExam }
                let finalExamCount = finalExamGrades.count + 1
                let totalFinalExamWeight = totalNonFinalExamWeight
                let individualFinalExamWeight = finalExamCount > 0 ? totalFinalExamWeight / Double(finalExamCount) : 0.0
                
                try realm.write {
                    for index in subject.grades.indices {
                        if subject.grades[index].isFinalExam {
                            subject.grades[index].weight = individualFinalExamWeight
                        }
                    }
                    
                    let newGrade = Grade()
                    newGrade.name = name
                    newGrade.score = score
                    newGrade.weight = individualFinalExamWeight
                    newGrade.date = date
                    newGrade.isFinalExam = true
                    subject.grades.append(newGrade)
                }
            }
        } catch let error as NSError {
            print("Fehler beim Hinzufügen der Abschlussprüfung: \(error.localizedDescription)")
        }
    }

    func updateSubject(subjectID: String, newName: String, isMaturarelevant: Bool) {
        do {
            if let subject = realm.object(ofType: Subject.self, forPrimaryKey: subjectID) {
                try realm.write {
                    subject.name = newName
                    subject.isMaturarelevant = isMaturarelevant
                }
            }
        } catch let error as NSError {
            print("Fehler beim Aktualisieren des Fachs: \(error.localizedDescription)")
        }
    }

    func deleteSubject(subjectID: String) {
        do {
            if let subject = realm.object(ofType: Subject.self, forPrimaryKey: subjectID) {
                try realm.write {
                    realm.delete(subject)
                }
            }
        } catch let error as NSError {
            print("Fehler beim Löschen des Fachs: \(error.localizedDescription)")
        }
    }

    func updateFinalExamWeights(for subjectID: String) {
        do {
            if let subject = realm.object(ofType: Subject.self, forPrimaryKey: subjectID) {
                let nonFinalGrades = subject.grades.filter { !$0.isFinalExam }
                let totalNonFinalExamWeight = nonFinalGrades.reduce(0) { $0 + $1.weight }
                let finalExamGrades = subject.grades.filter { $0.isFinalExam }
                let totalFinalExamWeight = totalNonFinalExamWeight
                let individualFinalExamWeight = finalExamGrades.isEmpty ? 0 : totalFinalExamWeight / Double(finalExamGrades.count)
                
                try realm.write {
                    for index in subject.grades.indices {
                        if subject.grades[index].isFinalExam {
                            subject.grades[index].weight = individualFinalExamWeight
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Fehler beim Aktualisieren der Abschlussprüfungsgewichtung: \(error.localizedDescription)")
        }
    }

    func copySubject(subjectID: String, toSemesterID: String) {
        do {
            if let subject = realm.object(ofType: Subject.self, forPrimaryKey: subjectID),
               let semester = realm.object(ofType: Semester.self, forPrimaryKey: toSemesterID) {
                let newSubject = Subject()
                newSubject.name = subject.name
                newSubject.isMaturarelevant = subject.isMaturarelevant
                newSubject.grades.append(objectsIn: subject.grades)
                
                try realm.write {
                    semester.subjects.append(newSubject)
                }
            }
        } catch let error as NSError {
            print("Fehler beim Kopieren des Fachs: \(error.localizedDescription)")
        }
    }
    func deleteAllContents() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}
