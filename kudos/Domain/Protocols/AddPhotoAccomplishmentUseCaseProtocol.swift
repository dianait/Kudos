import Foundation

@MainActor
protocol AddPhotoAccomplishmentUseCaseProtocol {
    func execute(photoData: Data, caption: String?) throws
}
