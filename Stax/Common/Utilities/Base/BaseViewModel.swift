//
//  BaseViewModel.swift
//  Stax
//
//  Created by Rovshan Rasulov on 11.12.25.
//

import Foundation

protocol BaseViewModel{
    associatedtype Input
    associatedtype Output
    
    var input: Input { get set }
    var output: Output { get set }
    
    func bind()
}
