//
//  DataSeeder.swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.12.25.
//

import Foundation
import CoreData

protocol DataSeederProtocol{
    func seedExercise() async
    func seed() async
}

final class DataSeeder: DataSeederProtocol{
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func seedExercise() async{
        
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        do{
            let count = try context.count(for: fetchRequest)
            
            if count > 0 { return }
            
            await seed()
            try context.save()
        } catch{
            print("Failed to fetch count of Exercise")
        }
    }
    
    
    func seed() async{
        
        //Finding json data
        guard let url = Bundle.main.url(forResource: "exercises_seed", withExtension: "json"),
        let data = try? Data(contentsOf: url) else {return}
        
        //Decoding
        let exerciseDTOs = try? JSONDecoder().decode([ExerciseDTO].self, from: data)
        
        //Mapping
        exerciseDTOs?.forEach { dto in
            let newExercise = Exercise(context: context)
            newExercise.name = dto.name
            newExercise.targetMuscle = dto.targetMuscle
            newExercise.exerciseImage = dto.exerciseImage
            
            if let staticUUID = UUID(uuidString: dto.id) {
                newExercise.id = staticUUID
            }
        }
        
        //Saving
        do{
            try context.save()
            print("Seeding data completed")
        } catch{
            print("Error\(DatabaseError.unknown(error.localizedDescription))")
        }
    }
}
