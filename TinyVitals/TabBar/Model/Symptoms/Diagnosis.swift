//
//  Diagnosis.swift
//  TinyVitals
//
//  Created by admin0 on 17/11/25.
//

import Foundation
import UIKit // Needed for UIImage or Data

struct Diagnosis {
    let id: UUID // A unique ID for this diagnosis
    let entryID: UUID // The ID of the SymptomEntry it's linked to
    
    let diagnosisName: String
    let diagnosedBy: String?
    let doctorName: String?
    let date: Date
    
    let notes: String?
    let photoData: Data?
    
}
