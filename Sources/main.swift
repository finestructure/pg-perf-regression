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
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    try await client.query("REFRESH MATERIALIZED VIEW recent_packages")
}

func runQuery002(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    try await client.query("REFRESH MATERIALIZED VIEW recent_releases")
}

func runQuery003(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    try await client.query("REFRESH MATERIALIZED VIEW search")
}

func runQuery004(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    try await client.query("REFRESH MATERIALIZED VIEW stats")
}

func runQuery005(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    try await client.query("REFRESH MATERIALIZED VIEW weighted_keywords")
}

func runQuery006(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select count(*) from (
            select distinct p.url
            from packages p
            join versions v on v.package_id = p.id
            where
            v.spi_manifest::text like '%documentation_targets%'
            and v.latest is not null
        ) t
        """)
    for try await res in rows.decode(Int.self) {
        if !quiet { print(#function, res) }
    }
}

func runQuery007(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select count(*) from (
            select d.updated_at, p.url, file_count, mb_size, v.latest,
                case
                    when v.latest = 'release' then v.reference->'tag'->>'tagName'
                    when v.latest = 'pre_release' then v.reference->'tag'->>'tagName'
                    when v.latest = 'default_branch' then v.reference->>'branch'
                end as "reference",
                d.status,
                d.error,
                d.log_url,
                b.job_url,
                version_id,
                platform,
                swift_version,
                build_id
            from doc_uploads d
            join builds b on b.id = d.build_id
            join versions v on v.id = b.version_id
            join packages p on v.package_id = p.id
            where d.status != 'ok'
            order by d.updated_at desc
        ) t
        """)
    for try await res in rows.decode(Int.self) {
        if !quiet { print(#function, res) }
    }
}

func runQuery008(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select owner, count(*)
        from repositories r
        join packages p on r.package_id = p.id
        join versions v on v.package_id = p.id
        where v.latest = 'default_branch'
        and v.spi_manifest::text like '%documentation_targets%'
        group by owner
        order by count(*) desc
        limit 10
        """)
    for try await res in rows.decode((String, Int).self) {
        if !quiet { print(#function, res) }
    }
}

func runQuery009(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select 'linux' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
            select distinct p.url
            from builds b
            join versions v on b.version_id = v.id
            join packages p on v.package_id = p.id
            where platform = 'linux'
            and b.status = 'ok'
        ) t
        union
        select 'macos' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
            select distinct p.url
            from builds b
            join versions v on b.version_id = v.id
            join packages p on v.package_id = p.id
            where (platform = 'macos-spm' or platform = 'macos-xcodebuild')
            and b.status = 'ok'
        ) t
        union
        select 'ios' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
            select distinct p.url
            from builds b
            join versions v on b.version_id = v.id
            join packages p on v.package_id = p.id
            where platform = 'ios'
            and b.status = 'ok'
        ) t
        union
        select 'tvos' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
            select distinct p.url
            from builds b
            join versions v on b.version_id = v.id
            join packages p on v.package_id = p.id
            where platform = 'tvos'
            and b.status = 'ok'
        ) t
        union
        select 'watchos' as "platform", count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
            select distinct p.url
            from builds b
            join versions v on b.version_id = v.id
            join packages p on v.package_id = p.id
            where platform = 'watchos'
            and b.status = 'ok'
        ) t
        """)
    // NB: odd thing but the `::decimal` cannot be decoded as Double or Float,
    // only works with Data!
    for try await res in rows.decode((String, Int, Data).self) {
        if !quiet { print(#function, res) }
    }
}

func runQuery010(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select url from packages
        where url not in (
            select p.url
            from packages p
            join versions v on v.package_id = p.id
            join builds b on b.version_id = v.id
            where 
            b.status = 'failed'
            group by p.url
        )
        limit 20
        """)
    for try await res in rows.decode(String.self) {
        if !quiet { print(#function, res) }
    }
}

func runQuery011(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select dependency, count(*) from (
            select p.url, unnest(resolved_dependencies)->>'repositoryURL' as dependency
            from versions v
            join packages p on v.package_id = p.id
            where 
            --package_id = 'ba6a7c68-3563-4783-bd88-24e209af7f0d' and
            latest = 'release'
        ) t
        group by dependency
        order by count(*) desc
        limit 20
        """)
    for try await res in rows.decode((String, Int).self) {
        if !quiet { print(#function, res) }
    }
}

func runQuery012(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select '6.0' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
        select distinct p.id
        from builds b
        join versions v on b.version_id = v.id
        join packages p on v.package_id = p.id 
        where swift_version->>'major' = '6' and swift_version->>'minor' = '0'
        and b.status = 'ok'
        ) t
        union
        select '5.10' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
        select distinct p.id
        from builds b
        join versions v on b.version_id = v.id
        join packages p on v.package_id = p.id 
        where swift_version->>'major' = '5' and swift_version->>'minor' = '10'
        and b.status = 'ok'
        ) t
        union
        select '5.9' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
        select distinct p.id
        from builds b
        join versions v on b.version_id = v.id
        join packages p on v.package_id = p.id 
        where swift_version->>'major' = '5' and swift_version->>'minor' = '9'
        and b.status = 'ok'
        ) t
        union
        select '5.8' as swift_version, count(t.*) as "total", round(count(t.*)*100 / (select count(*) from packages)::decimal, 1) as "fraction" from
        (
        select distinct p.id
        from builds b
        join versions v on b.version_id = v.id
        join packages p on v.package_id = p.id 
        where swift_version->>'major' = '5' and swift_version->>'minor' = '8'
        and b.status = 'ok'
        ) t
        """)
    // NB: odd thing but the `::decimal` cannot be decoded as Double or Float,
    // only works with Data!
    for try await res in rows.decode((String, Int, Data).self) {
        if !quiet { print(#function, res) }
    }
}

func runQuery013(_ client: PostgresClient, quiet: Bool = false) async throws {
    let start = Date()
    defer { if !quiet { print("\(#function): \(Date().timeIntervalSince(start))s") } }
    let rows = try await client.query("""
        select '5.8' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '5' and swift_version->>'minor' = '8')::decimal, 1) as "fraction"
        from builds b
        where swift_version->>'major' = '5' and swift_version->>'minor' = '8'
        and b.status = 'ok'
        union
        select '5.9' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '5' and swift_version->>'minor' = '9')::decimal, 1) as "fraction"
        from builds b
        where swift_version->>'major' = '5' and swift_version->>'minor' = '9'
        and b.status = 'ok'
        union
        select '5.10' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '5' and swift_version->>'minor' = '10')::decimal, 1) as "fraction"
        from builds b
        where swift_version->>'major' = '5' and swift_version->>'minor' = '10'
        and b.status = 'ok'
        union
        select '6.0' as swift_version, count(*) as "total", round(count(*)*100 / (select count(*) from builds where swift_version->>'major' = '6' and swift_version->>'minor' = '0')::decimal, 1) as "fraction"
        from builds b
        where swift_version->>'major' = '6' and swift_version->>'minor' = '0'
        and b.status = 'ok'
        """)
    // NB: odd thing but the `::decimal` cannot be decoded as Double or Float,
    // only works with Data!
    for try await res in rows.decode((String, Int, Data).self) {
        if !quiet { print(#function, res) }
    }
}


func main() async throws {
    for port in [6432, 7432] {
        print("Testing DB on port \(port)")

        for _ in (1...10) {
            let start = Date()
            defer { print("    \(Date().timeIntervalSince(start))s")}

            let quiet = true
            try await withDatabase(port: port) { client in
                try await runQuery001(client, quiet: quiet)
                try await runQuery002(client, quiet: quiet)
                try await runQuery003(client, quiet: quiet)
                try await runQuery004(client, quiet: quiet)
                try await runQuery005(client, quiet: quiet)
                try await runQuery006(client, quiet: quiet)
                try await runQuery007(client, quiet: quiet)
                try await runQuery008(client, quiet: quiet)
                try await runQuery009(client, quiet: quiet)
                try await runQuery010(client, quiet: quiet)
                try await runQuery011(client, quiet: quiet)
                try await runQuery012(client, quiet: quiet)
                try await runQuery013(client, quiet: quiet)
            }
        }
    }
}

try await main()
