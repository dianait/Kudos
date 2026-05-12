import Foundation

enum Links {
    private static let landingBase = "https://dianait.blog/kudos"

    static func landing(for language: String) -> URL {
        if language == "en" {
            return URL(string: "\(landingBase)/in")!
        }
        return URL(string: landingBase)!
    }
}

struct SocialLink {
    let name: String
    let iconName: String
    let url: URL
}

let socialLinks: [SocialLink] = [
    SocialLink(
        name: "gitHub",
        iconName: CustomImage.github.rawValue,
        url: URL(string: "https://github.com/dianait")!
    ),
    SocialLink(
        name: "twitter",
        iconName: CustomImage.twitter.rawValue,
        url: URL(string: "https://twitter.com/dianait_")!
    ),
    SocialLink(
        name: "linkedin",
        iconName: CustomImage.linkedin.rawValue,
        url: URL(string: "https://www.linkedin.com/in/dianahdezsoler/")!
    ),
]
