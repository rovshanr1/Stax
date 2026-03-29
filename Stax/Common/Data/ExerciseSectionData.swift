//
//  ExerciseSectionData.swift
//  Stax
//
//  Created by Rovshan Rasulov on 29.03.26.
//

import Foundation

struct ExerciseSectionData{
    let sectionID = UUID()
    let headerItem: DetailExerciseHeaderItem
    let items: [DetailSetRowItem]
}
