import Foundation

protocol AddPhotoAccomplishmentUseCaseProtocol {
    func execute(photoData: Data, caption: String?) throws
}
