import PostgresNIO
import Foundation

let port = 6432
let config = PostgresClient.Configuration(host: "localhost", port: port, username: "spi_dev", password: "xxx", database: "spi_dev", tls: .disable)
let client = PostgresClient(configuration: config)

try await withThrowingTaskGroup(of: Void.self) { taskGroup in
    taskGroup.addTask {
        await client.run()
    }

    let rows = try await client.query("SELECT id, url FROM packages")

    for try await (id, url) in rows.decode((UUID, String).self) {
    }

    taskGroup.cancelAll()
}
