//
//  MedicalRecords.swift
//  TinyVitals
//
//  Created by admin0 on 11/11/25.
//

import UIKit

struct MedicalRecord: Codable {
    
    // FIX: The 'id' property is excluded from Codable conformance
    // but remains initialized when creating a new instance.
    let id: UUID
    var type: String          // e.g., "CT-Chest Scan", "X-Ray"
    var source: String        // e.g., "Dr. Raj Kumar's Clinic"
    var dateAdded: Date
    let fileURL: URL?         // Path to the stored file

    // 1. Define CodingKeys to list only the properties that should be encoded/decoded.
    // We intentionally omit 'id' because it's set locally on creation.
    private enum CodingKeys: String, CodingKey {
        case type
        case source
        case dateAdded
        case fileURL
        // If you need the ID to be saved/loaded, you MUST include it here.
        // For simplicity, we assume ID is only created client-side.
    }
    
    // Default initializer (used when creating a NEW record)
    init(type: String, source: String, dateAdded: Date, fileURL: URL?) {
        self.id = UUID() // Initial value set here
        self.type = type
        self.source = source
        self.dateAdded = dateAdded
        self.fileURL = fileURL
    }

    // Custom initializer required by Decodable (used when LOADING a record)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Use default value for 'id' during decoding, or handle it as needed.
        // If you intended to save the ID, you would try to decode it here.
        // For now, we initialize a new ID, effectively ignoring the stored ID in this simple version.
        self.id = UUID()
        
        // Decode all other properties
        self.type = try container.decode(String.self, forKey: .type)
        self.source = try container.decode(String.self, forKey: .source)
        self.dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        self.fileURL = try container.decodeIfPresent(URL.self, forKey: .fileURL)
    }

    // We can add a simple computed property for display formatting
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        return formatter.string(from: dateAdded)
    }
}
