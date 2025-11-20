//
//  MedicalRecords.swift
//  TinyVitals
//
//  Created by admin0 on 11/11/25.
//

import UIKit

struct MedicalRecord: Codable {
    let id: UUID
    var type: String
    var source: String
    var dateAdded: Date
    let fileURL: URL?
    private enum CodingKeys: String, CodingKey {
        case type
        case source
        case dateAdded
        case fileURL
    }
    init(type: String, source: String, dateAdded: Date, fileURL: URL?) {
        self.id = UUID()
        self.type = type
        self.source = source
        self.dateAdded = dateAdded
        self.fileURL = fileURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.type = try container.decode(String.self, forKey: .type)
        self.source = try container.decode(String.self, forKey: .source)
        self.dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        self.fileURL = try container.decodeIfPresent(URL.self, forKey: .fileURL)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        return formatter.string(from: dateAdded)
    }
}
