import SwiftUI

struct SocialLinks: View {
    var body: some View {
        VStack {
            Text(Copies.AboutMe.Footer.title)
                .font(.caption)
            Text(Copies.AboutMe.Footer.socialLinks)
                .font(.footnote)
                .foregroundStyle(.gray)

            HStack(spacing: Space.mediumLarge) {
                ForEach(socialLinks, id: \.name) { link in
                    Button(action: {
                        UIApplication.shared.open(link.url)
                    }) {
                        VStack {
                            Image(link.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Space.mediumLarge, height: Space.mediumLarge)

                            Text(link.name)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(.rect(cornerRadius: Space.small))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top)
        .background(Color("MainBackground"))
    }
}

#Preview {
    SocialLinks()
}
