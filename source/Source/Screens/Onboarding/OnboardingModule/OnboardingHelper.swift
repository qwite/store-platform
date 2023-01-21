//
//  UIOnboardingHelper.swift
//  UIOnboarding Demo
//
//

import UIKit
import UIOnboarding

struct UIOnboardingHelper {
    static func setUpTitle() -> NSMutableAttributedString {
        let welcomeText: NSMutableAttributedString = .init(string: "Создай свой\nбренд",
                                                           attributes: [.foregroundColor: UIColor.label]),
            appNameText: NSMutableAttributedString = .init(string: Bundle.main.displayName ?? "\nодежды",
                                                           attributes: [.foregroundColor: UIColor.label])
        welcomeText.append(appNameText)
        return welcomeText
    }
    
    static func setUpFeatures() -> Array<UIOnboardingFeature> {
        return .init([
            .init(icon: UIImage(systemName: "book")!,
                  title: "Search until found",
                  description: "Over a hundred insignia of the Swiss Armed Forces – each redesigned from the ground up."),
            .init(icon: UIImage(systemName: "book")!,
                  title: "Enlist prepared",
                  description: "Practice with the app and pass the rank test on the first run."),
            .init(icon: UIImage(systemName: "book")!,
                  title: "#teamarmee",
                  description: "Add name tags of your comrades or cadre. Insignia automatically keeps every name tag you create in iCloud.")
        ])
    }
    
    static func setUpNotice() -> UIOnboardingTextViewConfiguration {
        return .init(icon: .init(systemName: "book")!,
                     text: "Developed and designed for members of the Swiss Armed Forces.",
                     linkTitle: "Learn more...",
                     link: "https://www.lukmanascic.ch/portfolio/insignia",
                     tint: UIColor.white)
    }
    
    static func setUpButton() -> UIOnboardingButtonConfiguration {
        return .init(title: "Продолжить",
                     backgroundColor: UIColor.black)
    }
}

extension UIOnboardingViewConfiguration {
    static func setUp() -> UIOnboardingViewConfiguration {
        return .init(
            appIcon: UIImage(), welcomeTitle: UIOnboardingHelper.setUpTitle(),
                     features: UIOnboardingHelper.setUpFeatures(),
                     textViewConfiguration: UIOnboardingHelper.setUpNotice(),
                     buttonConfiguration: UIOnboardingHelper.setUpButton())
    }
}
