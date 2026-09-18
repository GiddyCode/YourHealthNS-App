import SwiftUI

enum HealthTheme {
    static let brandBlue = Color("BrandBlue")
    static let brandCyan = Color("BrandCyan")
    static let brandGreen = Color("BrandGreen")
    static let brandGray = Color("BrandGray")

    static let canvas = Color("Canvas")
    static let surface = Color("Surface")
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let action = Color("AccentColor")
    static let actionText = Color("ActionText")
    static let border = Color("Border")

    enum Space {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let regular: CGFloat = 16
        static let screen: CGFloat = 20
        static let large: CGFloat = 24
        static let section: CGFloat = 32
    }

    enum Radius {
        static let control: CGFloat = 14
        static let illustration: CGFloat = 16
        static let surface: CGFloat = 20
    }

    static let contentWidth: CGFloat = 680
    static let wordmarkWidth: CGFloat = 209
    static let microscopeSize: CGFloat = 88
    static let minimumControlHeight: CGFloat = 48
}
