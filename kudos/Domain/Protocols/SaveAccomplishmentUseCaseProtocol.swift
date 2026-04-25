import Foundation

@MainActor
protocol SaveAccomplishmentUseCaseProtocol {
    func execute(text: String, photoData: Data?) throws
}
