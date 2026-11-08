//
//  WorkoutSessionMappersTests.swift
//  StaxTests
//
//  Created by Rovshan Rasulov on 08.11.26.
//

import XCTest
import CoreData
@testable import Stax

@MainActor
final class WorkoutSessionMapperTests: XCTestCase {

    private var context: NSManagedObjectContext!
    private var workoutRepo: DataRepository<Workout>!
    private var exerciseRepo: DataRepository<WorkoutExercise>!
    private var setRepo: DataRepository<WorkoutSet>!
    private var baseRepo: DataRepository<Exercise>!

    override func setUp() async throws {
        try await super.setUp()
        context = TestCoreData.makeContext()
        workoutRepo = DataRepository(context: context)
        exerciseRepo = DataRepository(context: context)
        setRepo = DataRepository(context: context)
        baseRepo = DataRepository(context: context)
    }

    override func tearDown() async throws {
        context = nil
        workoutRepo = nil
        exerciseRepo = nil
        setRepo = nil
        baseRepo = nil
        try await super.tearDown()
    }

    //MARK: - Stats
    func test_stats_countOnlyCompletedSets() {
        let workout = makeWorkout(sets: [(100, 5, true), (100, 5, false), (60, 10, true)])

        let result = WorkoutSessionMapper.map(workout, previousSets: [:])

        XCTAssertEqual(result.completedSets, 2)
        XCTAssertEqual(result.volume, 1100)
    }

    func test_stats_emptyWorkout_isZero() {
        let workout = makeWorkout(sets: [])

        let result = WorkoutSessionMapper.map(workout, previousSets: [:])

        XCTAssertTrue(result.exercises[0].workoutSets.isEmpty)
        XCTAssertEqual(result.completedSets, 0)
        XCTAssertEqual(result.volume, 0)
    }

    //MARK: - Ordering
    func test_sets_areSortedByOrderIndex() {
        let workout = makeWorkout(sets: [(30, 1, false), (10, 1, false), (20, 1, false)],
                                  orderIndexes: [2, 0, 1])

        let sets = WorkoutSessionMapper.map(workout, previousSets: [:]).exercises[0].workoutSets

        XCTAssertEqual(sets.map(\.weight), [10, 20, 30])
    }

    func test_exercises_areSortedByOrderIndex() {
        let workout = workoutRepo.create()
        workout.id = UUID()

        for (name, index) in [("C", 2), ("A", 0), ("B", 1)] {
            let base = baseRepo.create()
            base.id = UUID()
            base.name = name

            let exercise = exerciseRepo.create()
            exercise.id = UUID()
            exercise.orderIndex = Int16(index)
            exercise.exercise = base
            exercise.workout = workout
        }

        let result = WorkoutSessionMapper.map(workout, previousSets: [:])

        XCTAssertEqual(result.exercises.map { $0.exercise?.name }, ["A", "B", "C"])
    }

    //MARK: - Previous sets
    func test_previous_isFormattedAndMatchedByIndex() {
        let workout = makeWorkout(sets: [(0, 0, false), (0, 0, false), (0, 0, false)])
        let baseID = workout.exerciseBaseID

        let previous: [String: [WorkoutSetDomainModel]] = [
            baseID: [makePastSet(weight: 82.5, reps: 8, index: 0),
                     makePastSet(weight: 80, reps: 6, index: 1)]
        ]

        let sets = WorkoutSessionMapper.map(workout, previousSets: previous)
            .exercises[0].workoutSets

        XCTAssertEqual(sets[0].previous, "82.5kg x 8")
        XCTAssertEqual(sets[1].previous, "80kg x 6")
        XCTAssertEqual(sets[0].previousWeight, 82.5)
        XCTAssertEqual(sets[1].previousReps, 6)
        XCTAssertEqual(sets[2].previous, "-")
        XCTAssertNil(sets[2].previousWeight)
        XCTAssertNil(sets[2].previousReps)
    }

    func test_previous_withoutHistory_isDash() {
        let workout = makeWorkout(sets: [(50, 10, false)])

        let set = WorkoutSessionMapper.map(workout, previousSets: [:])
            .exercises[0].workoutSets[0]

        XCTAssertEqual(set.previous, "-")
    }

    //MARK: - IDs
    func test_ids_areStableBetweenMappings() {
        let workout = makeWorkout(sets: [(50, 10, false), (50, 10, true)])

        let first = WorkoutSessionMapper.map(workout, previousSets: [:])
        let second = WorkoutSessionMapper.map(workout, previousSets: [:])

        XCTAssertEqual(first.exercises.map(\.id), second.exercises.map(\.id))
        XCTAssertEqual(first.exercises[0].workoutSets.map(\.id),
                       second.exercises[0].workoutSets.map(\.id))
    }
}

//MARK: - Helpers
private extension WorkoutSessionMapperTests {

    func makeWorkout(sets: [(weight: Double, reps: Int16, done: Bool)],
                     orderIndexes: [Int]? = nil) -> Workout {
        let workout = workoutRepo.create()
        workout.id = UUID()

        let base = baseRepo.create()
        base.id = UUID()
        base.name = "Bench Press"

        let exercise = exerciseRepo.create()
        exercise.id = UUID()
        exercise.orderIndex = 0
        exercise.exercise = base
        exercise.workout = workout

        for (index, item) in sets.enumerated() {
            let set = setRepo.create()
            set.id = UUID()
            set.orderIndex = Int16(orderIndexes?[index] ?? index)
            set.weight = item.weight
            set.reps = item.reps
            set.isCompleted = item.done
            set.workoutExercise = exercise
        }
        return workout
    }

    func makePastSet(weight: Double, reps: Int16, index: Int16) -> WorkoutSetDomainModel {
        WorkoutSetDomainModel(id: UUID().uuidString,
                              isCompleted: true,
                              orderIndex: index,
                              previous: "-",
                              reps: reps,
                              restTime: 0,
                              weight: weight,
                              previousWeight: nil,
                              previousReps: nil)
    }
}

private extension Workout {
    
    var exerciseBaseID: String {
        let exercises = workoutExercises as? Set<WorkoutExercise> ?? []
        return exercises.first?.exercise?.id?.uuidString ?? ""
    }
}
