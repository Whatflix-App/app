import Foundation

extension String {
    var isProbablyEmail: Bool {
        contains("@") && contains(".")
    }
}
