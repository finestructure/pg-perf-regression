import XCTest

import PostgresNIO


private func connect(to databaseName: String) async throws -> PostgresClient {
    let host = "localhost"
    let port = 5432
    let username = "spi_test"
    let password = "xxx"

    let config = PostgresClient.Configuration(host: host, port: port, username: username, password: password, database: databaseName, tls: .disable)

    return .init(configuration: config)
}


private func withDatabase(_ databaseName: String, _ query: @escaping (PostgresClient) async throws -> Void) async throws {
    let client = try await connect(to: databaseName)
    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
        taskGroup.addTask { await client.run() }

        try await query(client)

        taskGroup.cancelAll()
    }
}


private func recreateDatabase(_ databaseName: String) async throws {
    try await withDatabase("postgres") {  // Connect to `postgres` db in order to reset the test db
        try await $0.query(PostgresQuery(unsafeSQL: "DROP DATABASE IF EXISTS \(databaseName) WITH (FORCE)"))
        try await $0.query(PostgresQuery(unsafeSQL: "CREATE DATABASE \(databaseName)"))
    }
}


private func createSnapshot(original: String, snapshot: String) async throws {
    let start = Date()
    defer { print("Elapsed:", #function, "\(Date.now.timeIntervalSince(start) * 1000)")}
    do {
        try await withDatabase("postgres") { client in
            try await client.query(PostgresQuery(unsafeSQL: "DROP DATABASE IF EXISTS \(snapshot) WITH (FORCE)"))
            try await client.query(PostgresQuery(unsafeSQL: "CREATE DATABASE \(snapshot) TEMPLATE \(original)"))
        }
    } catch {
        print("Create snapshot failed with error: ", String(reflecting: error))
        throw error
    }
}


class PerfTest: XCTestCase {
    func test1() async throws {
        let testDbName = "spi_test"
        let snapshotName = testDbName + "_snapshot"

        try await recreateDatabase(testDbName)
        try await recreateDatabase(testDbName)
        try await createSnapshot(original: testDbName, snapshot: snapshotName)
    }

    func test2() async throws {
        let testDbName = "spi_test"
        let snapshotName = testDbName + "_snapshot"

        try await recreateDatabase(testDbName)
        try await createSnapshot(original: testDbName, snapshot: snapshotName)
    }

    func test3() async throws {
        let testDbName = "spi_test"
        let snapshotName = testDbName + "_snapshot"

        try await createSnapshot(original: testDbName, snapshot: snapshotName)
    }
}
