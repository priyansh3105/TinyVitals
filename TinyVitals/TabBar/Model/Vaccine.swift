//
//  Vaccine.swift
//  TinyVitals
//
//  Created by admin0 on 14/11/25.
//

import Foundation
enum VaccinationSchedule: String, CaseIterable {
    case atBirth = "Birth"
    case sixWeeks = "6 Weeks"
    case tenWeeks = "10 Weeks"
    case fourteenWeeks = "14 Weeks"
    case sixMonths = "6 Months"
    case nineMonths = "9 Months"
    case twelveMonths = "12 Months"
    case fifteenMonths = "15 Months"
    case eighteenMonths = "18 Months"
    case twoYears = "2 Years"
    case fourToSixYears = "4-6 Years"
    case tenToTwelveYears = "10-12 Years"
}

enum VaccinationStatus {
    case due
    case completed
    case skipped
    case reschedule
}

struct Vaccine {
    let name: String
    let description: String
    let schedule: VaccinationSchedule
    let status: VaccinationStatus
    let notes: String?
    let givenDate: Date?
    let photoData: Data? // <<< ADD THIS PROPERTY
}

