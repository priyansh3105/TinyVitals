//
//  SymptomEntry.swift
//  TinyVitals
//
//  Created by admin0 on 17/11/25.
//

import Foundation
import UIKit

struct SymptomEntry {
    let id: UUID
    let date: Date
    
    let title: String
    let description: String?
    
    let symptoms: [String]
    
    // Vitals
    let temperature: Double?
    let weight: Double?
    let height: Double?
    
    let notes: String?
    let photoData: Data?
    
    // Fields for linking
    var diagnosisID: UUID?
    let diagnosedBy: String?
}
