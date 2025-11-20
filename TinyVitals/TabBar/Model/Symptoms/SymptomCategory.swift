//
//  SymptomCategory.swift
//  TinyVitals
//
//  Created by admin0 on 18/11/25.
//

import UIKit

// NEW: This struct will hold our categories
struct SymptomCategory {
    let name: String // e.g., "General", "Vision"
    var symptoms: [String]
}

// (The delegate protocol remains the same)
protocol SymptomSelectionDelegate: AnyObject {
    func didSelectSymptoms(_ symptoms: [String])
}
