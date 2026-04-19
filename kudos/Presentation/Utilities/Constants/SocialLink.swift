import Foundation

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
        name: "bluesky",
        iconName: CustomImage.bluesky.rawValue,
        url: URL(string: "https://bsky.app/profile/dianait.dev")!
    ),
    SocialLink(
        name: "linkedin",
        iconName: CustomImage.linkedin.rawValue,
        url: URL(string: "https://www.linkedin.com/in/dianahdezsoler/")!
    ),
]
