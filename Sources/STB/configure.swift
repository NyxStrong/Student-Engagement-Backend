import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    
    // 2. Register middleware at the beginning of the chain
    app.middleware.use(CORSMiddleware(configuration: corsConfiguration), at: .beginning)

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(Create())
    app.migrations.add(CreatePointView())
    app.migrations.add(SeedData())

    // register routes
    try routes(app)
}
