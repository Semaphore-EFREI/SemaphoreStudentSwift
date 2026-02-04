//
//  Date+Extensions.swift
//  SemaphoreStudentSwift
//
//  Created by Thomas Le Bonnec on 04/02/2026.
//

import Foundation

extension Date {
    func isSameDay(_ otherDate: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: otherDate)
    }
    
    func isBetween(_ start: Date, and end: Date, inclusive: Bool = true) -> Bool {
        let minDate = min(start, end)
        let maxDate = max(start, end)

        if inclusive {
            return self >= minDate && self <= maxDate
        } else {
            return self > minDate && self < maxDate
        }
    }
}
