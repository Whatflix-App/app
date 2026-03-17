import Foundation
import Testing
@testable import app

struct DateFormattingTests {
    @Test func watchLabelUsesTodayYesterdayWeekdayAndDateThresholds() {
        let calendar = Calendar.current
        let now = Date()

        let today = now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)!

        #expect(today.watchLabel == "Today")
        #expect(yesterday.watchLabel == "Yesterday")
        #expect(threeDaysAgo.watchLabel == weekdayString(for: threeDaysAgo))
        #expect(sevenDaysAgo.watchLabel == mediumDateString(for: sevenDaysAgo))
    }

    private func weekdayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func mediumDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
