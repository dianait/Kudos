import Foundation
import SwiftData

/// Where the kudos live and how each process opens them. Compiled into the app
/// and the widget.
enum KudosStore {
    static let appGroupID = "group.dev.dianait.kudosapp"
    static let cloudKitContainerID = "iCloud.dev.dianait.kudosapp"

    static var schema: Schema { Schema(versionedSchema: KudosSchemaV2.self) }

    /// The store before the widget existed: SwiftData's default location.
    static var legacyStoreURL: URL {
        URL.applicationSupportDirectory.appending(path: "default.store")
    }

    /// The store inside the App Group, readable by the widget. nil when the
    /// process has no App Group container.
    static var sharedStoreURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appending(path: "Library/Application Support/Kudos.store")
    }

    /// The one container of the app process, shared by the UI and App Intents:
    /// two containers syncing the same store with CloudKit would fight.
    @MainActor static let appContainer: Result<ModelContainer, any Error> = Result {
        try makeAppContainer()
    }

    /// Opens the app's store in the App Group (copying the pre-widget store
    /// there once) with iCloud sync. If CloudKit can't be set up (e.g. a build
    /// without the iCloud entitlement) the same store opens without sync, so
    /// the user's data is never swapped for an empty store.
    static func makeAppContainer() throws -> ModelContainer {
        var url = legacyStoreURL
        if let sharedURL = sharedStoreURL, copyStoreIfNeeded(from: legacyStoreURL, to: sharedURL) {
            url = sharedURL
        }
        do {
            return try makeContainer(url: url, cloudKitDatabase: .private(cloudKitContainerID))
        } catch {
            print("iCloud sync unavailable, opening the store locally: \(error)")
            return try makeContainer(url: url, cloudKitDatabase: .none)
        }
    }

    /// Read-only view for the widget. nil until the app has created the store.
    static func makeReadOnlyContainer() throws -> ModelContainer? {
        guard let url = sharedStoreURL,
              FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
        else { return nil }
        let configuration = ModelConfiguration(
            schema: schema, url: url, allowsSave: false, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func makeContainer(
        url: URL,
        cloudKitDatabase: ModelConfiguration.CloudKitDatabase
    ) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema, url: url, cloudKitDatabase: cloudKitDatabase)
        return try ModelContainer(
            for: schema, migrationPlan: KudosMigrationPlan.self, configurations: [configuration])
    }

    /// Copies (never moves) an existing store to `destination`, so the original
    /// stays behind as a backup. The main file is written last and atomically:
    /// its presence means the copy finished, even if the app was killed midway.
    /// Returns whether `destination` can be used.
    static func copyStoreIfNeeded(from source: URL, to destination: URL) -> Bool {
        let fileManager = FileManager.default
        let sourcePath = source.path(percentEncoded: false)
        let destinationPath = destination.path(percentEncoded: false)
        if fileManager.fileExists(atPath: destinationPath) { return true }
        guard fileManager.fileExists(atPath: sourcePath) else { return true }

        let sidecars = ["-wal", "-shm"]
        let temporaryPath = destinationPath + ".copying"
        do {
            try fileManager.createDirectory(
                at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            for suffix in sidecars where fileManager.fileExists(atPath: sourcePath + suffix) {
                try? fileManager.removeItem(atPath: destinationPath + suffix)
                try fileManager.copyItem(atPath: sourcePath + suffix, toPath: destinationPath + suffix)
            }
            try? fileManager.removeItem(atPath: temporaryPath)
            try fileManager.copyItem(atPath: sourcePath, toPath: temporaryPath)
            try fileManager.moveItem(atPath: temporaryPath, toPath: destinationPath)
            return true
        } catch {
            print("Could not copy the store to the App Group: \(error)")
            for path in sidecars.map({ destinationPath + $0 }) + [temporaryPath] {
                try? fileManager.removeItem(atPath: path)
            }
            return false
        }
    }
}
