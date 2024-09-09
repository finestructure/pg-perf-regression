import PostgresNIO
import Foundation

func connect(port: Int) async throws -> PostgresClient {
    let host = "localhost"
    let dbName = "spi_dev"
    let username = "spi_dev"
    let password = "xxx"
    let config = PostgresClient.Configuration(host: host, port: port, username: username, password: password, database: dbName, tls: .disable)
    return .init(configuration: config)
}


func withDatabase(port: Int, _ query: @escaping (PostgresClient) async throws -> Void) async throws {
    let client = try await connect(port: port)
    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
        taskGroup.addTask { await client.run() }
        try await query(client)
        taskGroup.cancelAll()
    }
}


func runQuery001(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))") } }
    try await client.query("DROP DATABASE IF EXISTS snapshot WITH (FORCE)")
    try await client.query("CREATE DATABASE snapshot TEMPLATE spi_dev")
}


func createSnapshot(port: Int, original: String, snapshot: String, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("Elapsed:", #function, "\(Date().timeIntervalSince(start))") } }
    do {
        try await withDatabase(port: port) { client in
            try await client.query(PostgresQuery(unsafeSQL: "DROP DATABASE IF EXISTS \(snapshot) WITH (FORCE)"))
            try await client.query(PostgresQuery(unsafeSQL: "CREATE DATABASE \(snapshot) TEMPLATE \(original)"))
        }
    } catch {
        print("Create snapshot failed with error: ", String(reflecting: error))
        throw error
    }
}



func main() async throws {
    for port in [6432, 7432] {
        print("Testing DB on port \(port)")

        for _ in (1...10) {
            let start = Date()
            defer { print("    \(Date().timeIntervalSince(start))s")}

            let quiet = true
            try await createSnapshot(port: port, original: "spi_dev", snapshot: "snapshot", quiet: quiet)
        }
    }
}

try await main()
