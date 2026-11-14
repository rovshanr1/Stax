//
//  DataSeeder.swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.12.25.
//

import Foundation
import CoreData

protocol DataSeederProtocol {
    func seedExercise() async
}

final class DataSeeder: DataSeederProtocol{
    let context: NSManagedObjectContext
    private let seedURL: URL?
    
    init(context: NSManagedObjectContext,
         seedURL: URL? = Bundle.main.url(forResource: "exercises_seed", withExtension: "json")) {
        self.context = context
        self.seedURL = seedURL
    }
    
    func seedExercise() async{
        
        do {
            let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
            guard try context.count(for: request) == 0 else { return }
        } catch {
            print("Seeder: count failed: \(error)")
            return
        }
        
        guard let dtos = await Self.loadSeedData() else { return }
        
        for dto in dtos {
            guard let id = UUID(uuidString: dto.id) else {
                print("Seeder: skipped exercise with invalid id: \(dto.name)")
                continue
            }
            
            let exercise = Exercise(context: context)
            exercise.id = id
            exercise.name = dto.name
            exercise.targetMuscle = dto.targetMuscle
            exercise.exerciseImage = dto.exerciseImage
            exercise.type = dto.type
        }
        do {
            try context.save()
            print("Seeding data completed")
        } catch {
            context.rollback()
            print("Seeder: save failed: \(error)")
        }
    }
    
    
    
    private static func loadSeedData() async -> [ExerciseDTO]? {
        await Task.detached(priority: .userInitiated) {
            guard let url = Bundle.main.url(forResource: "exercises_seed", withExtension: "json") else {
                print("Seeder: exercises_seed.json not found in bundle")
                return nil
            }
            
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode([ExerciseDTO].self, from: data)
            } catch {
                print("Seeder: decoding failed: \(error)")
                return nil
            }
        }.value
    }
}

