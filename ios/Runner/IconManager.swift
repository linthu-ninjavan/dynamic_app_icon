//
//  IconManager.swift
//  Runner
//
//  Created by Raman Tank on 09/01/25.
//


import Combine
import Foundation
import UIKit

enum Icon: String, CaseIterable, Identifiable {
    case primary = "ic_launcher_one"
    case second = "ic_launcher_two"
    case third = "ic_launcher_three"

    var id: String { self.rawValue }
}

class Model: ObservableObject, Equatable {
    @Published var appIcon: Icon = .primary

    static func == (lhs: Model, rhs: Model) -> Bool {
        return lhs.appIcon == rhs.appIcon
    }

    /// Change the app icon.
    /// - Tag: setAlternateAppIcon
    func setAlternateAppIcon(icon: Icon) {
            // Set the icon name to nil to use the primary icon.
            let iconName: String? = (icon == .primary) ? nil : icon.rawValue
            print("Attempting to change icon to: \(String(describing: iconName))")

            // Avoid setting the name if the app already uses that icon.
            guard UIApplication.shared.alternateIconName != iconName else { return }

            DispatchQueue.main.async {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    print("Error setting alternate icon: \(error.localizedDescription)")
                } else {
                    print("Successfully changed icon to: \(String(describing: iconName))")
                }
            }
        }

            appIcon = icon
    }

    /// Initializes the model with the current state of the app's icon.
    init() {
        let iconName = UIApplication.shared.alternateIconName

        if iconName == nil {
            appIcon = .primary
        } else {
            appIcon = Icon(rawValue: iconName!) ?? .primary
        }
    }
}
