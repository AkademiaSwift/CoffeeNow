import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a MySQL database
    let mysql = try MySQLDatabase(config: MySQLDatabaseConfig(
        hostname: "sotarsoft.pl",
        port: 3306,
        username: "domomat_coffeenow",
        password: "bahfow-posKe2-tekfef",
        database: "domomat_coffeenow",
        capabilities: MySQLCapabilities.default,
        characterSet: MySQLCharacterSet.utf8_general_ci,
        transport: MySQLTransportConfig.cleartext))

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: CoffeeHouse.self, database: .mysql)
    migrations.add(model: Location.self, database: .mysql)
    migrations.add(model: MenuCategory.self, database: .mysql)
    migrations.add(model: MenuItem.self, database: .mysql)
    migrations.add(model: Product.self, database: .mysql)
    migrations.add(model: ProductIngredientDescription.self, database: .mysql)
    migrations.add(model: ProductIngredient.self, database: .mysql)
    migrations.add(model: ProductSize.self, database: .mysql)
    migrations.add(model: ProductAdditional.self, database: .mysql)
    migrations.add(model: Session.self, database: .mysql)
    migrations.add(model: Piggy.self, database: .mysql)
    migrations.add(model: Paycard.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Order.self, database: .mysql)
    migrations.add(model: OrderItem.self, database: .mysql)
    migrations.add(model: OrderItemAdditional.self, database: .mysql)
    migrations.add(model: FavouriteOrder.self, database: .mysql)
    migrations.add(model: FavouriteOrderItem.self, database: .mysql)
    migrations.add(model: FavouriteOrderItemAdditional.self, database: .mysql)
    migrations.add(model: FavouriteCoffeeHouse.self, database: .mysql)
    services.register(migrations)
}
