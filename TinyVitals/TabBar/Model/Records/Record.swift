//
//  Record.swift
//  TinyVitals
//
//  Created by admin0 on 11/11/25.
//

import Foundation

struct Record {
    let fileName: String
    let source: String
    let addedDate: Date
    let type: String
    let fileURL: URL?
    let sectionName: String
    var previewData: Data?
}
