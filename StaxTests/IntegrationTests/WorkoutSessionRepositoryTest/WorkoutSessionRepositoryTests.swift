//
//  WorkoutSessionRepositoryTests.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 08.11.26.
//

import XCTest
import CoreData
import Combine
@testable import Stax

@MainActor
final class WorkoutSessionRepositoryTests: XCTestCase {

    private var context: NSManagedObjectContext!
    private var baseRepo: DataRepository<Exercise>!
    private var exerciseRepo: DataRepository<WorkoutExercise>!
    private var setRepo: DataRepository<WorkoutSet>!
    private var workoutRepo: DataRepository<Workout>!
    private var sut: WorkoutSessionRepository!

    private var cancellables = Set<AnyCancellable>()

    /// Repository-nin son yaydığı dəyərlər
    private var exercises: [WorkoutExerciseDomainModel] = []
    private var stats: (volume: Double, sets: Int) = (0, 0)

    //MARK: - Lifecycle
    override func setUp() async throws {
        try await super.setUp()

        context = TestCoreData.makeContext()
        baseRepo = DataRepository(context: context)
        exerciseRepo = DataRepository(context: context)
        setRepo = DataRepository(context: context)
        workoutRepo = DataRepository(context: context)

        sut = WorkoutSessionRepository(baseExerciseRepo: baseRepo,
                                       exerciseRepo: exerciseRepo,
                                       workoutSets: setRepo,
                                       workoutRepo: workoutRepo)

        sut.exercisesPublisher
            .sink { [weak self] in self?.exercises = $0 }
            .store(in: &cancellables)

        sut.sessionStatsPublisher
            .sink { [weak self] in self?.stats = $0 }
            .store(in: &cancellables)
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        sut = nil
        workoutRepo = nil
        setRepo = nil
        exerciseRepo = nil
        baseRepo = nil
        context = nil
        exercises = []
        try await super.tearDown()
    }

    //MARK: - Session
    func test_setupSession_newWorkout_startsEmpty() {
        let result = sut.setupSession(workoutID: nil)

        XCTAssertFalse(result.id.isEmpty)
        XCTAssertEqual(result.initialDuration, 0)
        XCTAssertEqual(sut.currentWorkoutID, result.id)
        XCTAssertTrue(exercises.isEmpty)
        XCTAssertEqual(stats.sets, 0)
        XCTAssertEqual(stats.volume, 0)
    }

    func test_setupSession_existingWorkout_loadsExercisesAndDuration() {
        let bench = makeBaseExercise(name: "Bench Press")
        let saved = seedWorkout(base: bench,
                                duration: 1800,
                                sets: [(80, 8, true), (80, 6, false)])
        let savedID = saved.id!.uuidString

        let result = sut.setupSession(workoutID: savedID)

        XCTAssertEqual(result.id, savedID)
        XCTAssertEqual(result.initialDuration, 1800)
        XCTAssertEqual(exercises.count, 1)
        XCTAssertEqual(exercises[0].workoutSets.count, 2)
        XCTAssertEqual(stats.sets, 1)
        XCTAssertEqual(stats.volume, 640)   // 80 * 8
    }

    func test_cancel_newWorkout_deletesDraftAndResetsState() async {
        let id = startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        await addExercise(bench, expectedCount: 1)

        sut.cancelWorkoutSession()
        await waitUntil { self.sut.currentWorkoutID == nil }

        XCTAssertNil(workoutRepo.fetch(by: id))
        XCTAssertTrue(exercises.isEmpty)
        XCTAssertEqual(stats.sets, 0)
    }

    func test_cancel_editMode_keepsWorkoutInStore() {
        let bench = makeBaseExercise(name: "Bench Press")
        let saved = seedWorkout(base: bench, duration: 1800, sets: [(80, 8, true)])
        let savedID = saved.id!.uuidString
        _ = sut.setupSession(workoutID: savedID)

        sut.cancelWorkoutSession()

        XCTAssertNotNil(workoutRepo.fetch(by: savedID))
        XCTAssertNil(sut.currentWorkoutID)
        XCTAssertTrue(exercises.isEmpty)
    }

    func test_finishWorkout_savesDuration() async {
        let id = startSession()

        sut.finishWorkout(duration: 300)
        await waitUntil { !self.context.hasChanges }

        XCTAssertEqual(workoutRepo.fetch(by: id)?.duration, 300)
    }

    //MARK: - Exercises
    func test_addExercise_createsExerciseWithOneEmptySet() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")

        await addExercise(bench, expectedCount: 1)

        let exercise = exercises[0]
        XCTAssertEqual(exercise.exercise?.name, "Bench Press")
        XCTAssertEqual(exercise.orderIndex, 0)
        XCTAssertEqual(exercise.workoutSets.count, 1)
        XCTAssertEqual(exercise.workoutSets[0].orderIndex, 0)
        XCTAssertFalse(exercise.workoutSets[0].isCompleted)
    }

    func test_addExercise_unknownID_doesNothing() {
        startSession()

        sut.addExercise(exerciseID: UUID().uuidString)

        XCTAssertTrue(exercises.isEmpty)
    }

    func test_addExercise_assignsIncreasingOrderIndex() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        let squat = makeBaseExercise(name: "Squat")

        await addExercise(bench, expectedCount: 1)
        await addExercise(squat, expectedCount: 2)

        XCTAssertEqual(exercises.map(\.orderIndex), [0, 1])
        XCTAssertEqual(exercises.map { $0.exercise?.name }, ["Bench Press", "Squat"])
    }

    func test_deleteExercise_reindexesRemaining() async {
        startSession()
        let base = makeBaseExercise(name: "Any")
        await addExercise(base, expectedCount: 1)
        await addExercise(base, expectedCount: 2)
        await addExercise(base, expectedCount: 3)

        let firstID = exercises[0].id
        let middleID = exercises[1].id
        let lastID = exercises[2].id

        sut.deleteExercise(workoutExerciseID: middleID)
        await waitUntil { self.exercises.count == 2 && self.exercises.map(\.orderIndex) == [0, 1] }

        XCTAssertEqual(exercises.map(\.id), [firstID, lastID])
    }

    func test_replaceExercise_keepsIdentityAndChangesDefinition() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        let squat = makeBaseExercise(name: "Squat")
        await addExercise(bench, expectedCount: 1)

        let originalID = exercises[0].id
        let originalSetIDs = exercises[0].workoutSets.map(\.id)

        sut.replaceExercise(workoutExerciseID: originalID, with: squat.id!.uuidString)
        await waitUntil { self.exercises.first?.exercise?.name == "Squat" }

        // Rest timer exercise ID-sinə bağlıdır: replace ID-ni dəyişməməlidir
        XCTAssertEqual(exercises[0].id, originalID)
        XCTAssertEqual(exercises[0].workoutSets.map(\.id), originalSetIDs)
    }

    func test_updateExerciseNote_isReflected() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        await addExercise(bench, expectedCount: 1)

        sut.updateExerciseNote(workoutExerciseID: exercises[0].id, note: "Heavy day")
        await waitUntil { self.exercises.first?.notes == "Heavy day" }

        XCTAssertEqual(exercises[0].notes, "Heavy day")
    }

    //MARK: - Sets
    func test_addNewSet_appendsWithIncreasingOrderIndex() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        await addExercise(bench, expectedCount: 1)

        await addSet(to: 0, expectedSets: 2)
        await addSet(to: 0, expectedSets: 3)

        XCTAssertEqual(exercises[0].workoutSets.map(\.orderIndex), [0, 1, 2])
    }

    func test_updateSet_done_updatesValuesAndStats() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        await addExercise(bench, expectedCount: 1)
        let setID = exercises[0].workoutSets[0].id

        sut.updateSet(setID: setID, weight: 100, reps: 5, isDone: true)
        await waitUntil { self.stats.sets == 1 }

        let updated = exercises[0].workoutSets[0]
        XCTAssertTrue(updated.isCompleted)
        XCTAssertEqual(updated.weight, 100)
        XCTAssertEqual(updated.reps, 5)
        XCTAssertEqual(stats.volume, 500)
    }

    func test_updateSet_undo_removesFromStats() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        await addExercise(bench, expectedCount: 1)
        let setID = exercises[0].workoutSets[0].id

        sut.updateSet(setID: setID, weight: 100, reps: 5, isDone: true)
        await waitUntil { self.stats.sets == 1 }

        sut.updateSet(setID: setID, weight: 100, reps: 5, isDone: false)
        await waitUntil { self.stats.sets == 0 }

        XCTAssertFalse(exercises[0].workoutSets[0].isCompleted)
        XCTAssertEqual(stats.volume, 0)
    }

    func test_updateSet_keepsExerciseAndSetIDsStable() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        await addExercise(bench, expectedCount: 1)
        let exerciseID = exercises[0].id
        let setID = exercises[0].workoutSets[0].id

        sut.updateSet(setID: setID, weight: 60, reps: 10, isDone: true)
        await waitUntil { self.stats.sets == 1 }

        // Diffable data source və rest timer ID-lərin sabit qalmasına arxalanır
        XCTAssertEqual(exercises[0].id, exerciseID)
        XCTAssertEqual(exercises[0].workoutSets[0].id, setID)
    }

    func test_deleteSet_reindexesRemaining() async {
        startSession()
        let bench = makeBaseExercise(name: "Bench Press")
        await addExercise(bench, expectedCount: 1)
        await addSet(to: 0, expectedSets: 2)
        await addSet(to: 0, expectedSets: 3)

        let ids = exercises[0].workoutSets.map(\.id)

        sut.deleteSet(setID: ids[1])
        await waitUntil {
            self.exercises[0].workoutSets.count == 2
            && self.exercises[0].workoutSets.map(\.orderIndex) == [0, 1]
        }

        XCTAssertEqual(exercises[0].workoutSets.map(\.id), [ids[0], ids[2]])
    }

    //MARK: - Previous sets
    func test_previousSets_areShownFromLastFinishedWorkout() async {
        let bench = makeBaseExercise(name: "Bench Press")
        seedWorkout(base: bench, sets: [(80, 8, true)])
        startSession()

        await addExercise(bench, expectedCount: 1)

        let set = exercises[0].workoutSets[0]
        XCTAssertEqual(set.previous, "80kg x 8")
        XCTAssertEqual(set.previousWeight, 80)
        XCTAssertEqual(set.previousReps, 8)
    }

    func test_previousSets_formatsFractionalWeight() async {
        let bench = makeBaseExercise(name: "Bench Press")
        seedWorkout(base: bench, sets: [(82.5, 8, true)])
        startSession()

        await addExercise(bench, expectedCount: 1)

        XCTAssertEqual(exercises[0].workoutSets[0].previous, "82.5kg x 8")
    }

    func test_previousSets_ignoreUnfinishedWorkouts() async {
        let bench = makeBaseExercise(name: "Bench Press")
        seedWorkout(base: bench, duration: 0, sets: [(80, 8, true)])
        startSession()

        await addExercise(bench, expectedCount: 1)

        XCTAssertEqual(exercises[0].workoutSets[0].previous, "-")
        XCTAssertNil(exercises[0].workoutSets[0].previousWeight)
    }

    func test_previousSets_ignoreWorkoutsWithoutCompletedSets() async {
        let bench = makeBaseExercise(name: "Bench Press")
        seedWorkout(base: bench, sets: [(80, 8, false)])
        startSession()

        await addExercise(bench, expectedCount: 1)

        XCTAssertEqual(exercises[0].workoutSets[0].previous, "-")
    }

    func test_previousSets_useMostRecentWorkout() async {
        let bench = makeBaseExercise(name: "Bench Press")
        seedWorkout(base: bench, daysAgo: 10, sets: [(60, 10, true)])
        seedWorkout(base: bench, daysAgo: 2, sets: [(90, 5, true)])
        startSession()

        await addExercise(bench, expectedCount: 1)

        XCTAssertEqual(exercises[0].workoutSets[0].previous, "90kg x 5")
    }

    func test_previousSets_areAlsoLoadedOnReplace() async {
        let bench = makeBaseExercise(name: "Bench Press")
        let squat = makeBaseExercise(name: "Squat")
        seedWorkout(base: squat, sets: [(120, 5, true)])
        startSession()
        await addExercise(bench, expectedCount: 1)

        sut.replaceExercise(workoutExerciseID: exercises[0].id, with: squat.id!.uuidString)
        await waitUntil { self.exercises.first?.exercise?.name == "Squat" }

        XCTAssertEqual(exercises[0].workoutSets[0].previous, "120kg x 5")
    }
}

//MARK: - Helpers
private extension WorkoutSessionRepositoryTests {

    @discardableResult
    func startSession() -> String {
        sut.setupSession(workoutID: nil).id
    }

    func makeBaseExercise(name: String) -> Exercise {
        let base = baseRepo.create()
        base.id = UUID()
        base.name = name
        try! context.save()
        return base
    }

    func addExercise(_ base: Exercise, expectedCount: Int,
                     file: StaticString = #filePath, line: UInt = #line) async {
        sut.addExercise(exerciseID: base.id!.uuidString)
        await waitUntil(file: file, line: line) { self.exercises.count == expectedCount }
    }

    func addSet(to exerciseIndex: Int, expectedSets: Int,
                file: StaticString = #filePath, line: UInt = #line) async {
        sut.addNewSet(to: exercises[exerciseIndex].id)
        await waitUntil(file: file, line: line) {
            self.exercises[exerciseIndex].workoutSets.count == expectedSets
        }
    }

    /// Əvvəlki (tarixçə) workout yaradır və saxlayır
    @discardableResult
    func seedWorkout(base: Exercise,
                     daysAgo: Int = 1,
                     duration: Double = 3600,
                     sets: [(weight: Double, reps: Int16, done: Bool)]) -> Workout {
        let workout = workoutRepo.create()
        workout.id = UUID()
        workout.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
        workout.duration = duration

        let workoutExercise = exerciseRepo.create()
        workoutExercise.id = UUID()
        workoutExercise.orderIndex = 0
        workoutExercise.exercise = base
        workoutExercise.workout = workout

        for (index, item) in sets.enumerated() {
            let set = setRepo.create()
            set.id = UUID()
            set.orderIndex = Int16(index)
            set.weight = item.weight
            set.reps = item.reps
            set.isCompleted = item.done
            set.workoutExercise = workoutExercise
        }

        try! context.save()
        return workout
    }

    /// Repository save-i `context.perform` ilə asinxrondur, ona görə şərt ödənənə qədər gözləyirik
    func waitUntil(timeout: TimeInterval = 2,
                   file: StaticString = #filePath,
                   line: UInt = #line,
                   _ condition: () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            if Date() > deadline {
                XCTFail("Şərt \(timeout) saniyə ərzində ödənmədi", file: file, line: line)
                return
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}
