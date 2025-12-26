//
//  DataSeeder.swift
//  Stax
//
//  Created by Rovshan Rasulov on 09.12.25.
//

import Foundation
import CoreData

struct DataSeeder{
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func seedExercise(){
        let fetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        do{
            let count = try context.count(for: fetchRequest)
            
            if count > 0 { return }
            
            seed()
            try context.save()
        } catch{
            print("Failed to fetch count of Exercise")
        }
        
       
    }
    
    func seed(){
        //UserDefaults control
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "seeded") == true { return }
        
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
            newExercise.id = UUID()
        }
        
        //Saving
        do{
            try context.save()
            userDefaults.set(true, forKey: "seeded")
            print("Seeding data complated")
        } catch{
            print("Error\(DatabaseError.unknown(error.localizedDescription))")
        }
    }
}
