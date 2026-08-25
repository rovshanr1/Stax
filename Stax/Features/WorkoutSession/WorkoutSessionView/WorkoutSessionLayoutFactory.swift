//
//  WorkoutSessionLayoutFactory.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.08.26.
//

import UIKit

enum WorkoutSessionLayoutFactory{
    static func createSection(for sectionType: WorkoutSessionSection) -> NSCollectionLayoutSection{
        let estimatedHeight: CGFloat
        
        switch sectionType{
        case .duration:
            estimatedHeight = 90
        case .exercises:
            estimatedHeight = 220
        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        let layoutSection = NSCollectionLayoutSection(group: group)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        layoutSection.interGroupSpacing = 12
        
        var supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
        
        switch sectionType{
        case .duration:
            let separatorSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1))
            let separator = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: separatorSize,
                elementKind: SectionSeparatorView.elementKind,
                alignment: .bottom
            )
            supplementaryItems.append(separator)
        case .exercises:
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: WorkoutSessionFooterView.elementKind,
                alignment: .bottom
            )
            sectionFooter.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 24, trailing: 0)
            supplementaryItems.append(sectionFooter)
        }
        
        layoutSection.boundarySupplementaryItems = supplementaryItems
        
        return layoutSection
    }
    
}
