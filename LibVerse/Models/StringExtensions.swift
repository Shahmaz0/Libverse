import Foundation

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
} 