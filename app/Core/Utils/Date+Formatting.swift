import Foundation

extension Date {
    var shortString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    var watchLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        }

        let startOfNow = calendar.startOfDay(for: Date())
        let startOfDate = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: startOfDate, to: startOfNow)
        if let day = components.day, day < 7 {
            return Self.weekdayFormatter.string(from: self)
        }

        return Self.mediumFormatter.string(from: self)
    }
}

private extension Date {
    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    static let mediumFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
