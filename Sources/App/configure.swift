import FluentSQLite
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: CoffeeHouse.self, database: .sqlite)
    migrations.add(model: Location.self, database: .sqlite)
    migrations.add(model: MenuCategory.self, database: .sqlite)
    migrations.add(model: MenuItem.self, database: .sqlite)
    migrations.add(model: Product.self, database: .sqlite)
    migrations.add(model: ProductIngredientDescription.self, database: .sqlite)
    migrations.add(model: ProductIngredient.self, database: .sqlite)
    migrations.add(model: ProductSize.self, database: .sqlite)
    migrations.add(model: ProductAdditional.self, database: .sqlite)
    migrations.add(model: Session.self, database: .sqlite)
    migrations.add(model: Piggy.self, database: .sqlite)
    migrations.add(model: Paycard.self, database: .sqlite)
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Order.self, database: .sqlite)
    migrations.add(model: OrderItem.self, database: .sqlite)
    migrations.add(model: OrderItemAdditional.self, database: .sqlite)
    migrations.add(model: FavouriteOrder.self, database: .sqlite)
    migrations.add(model: FavouriteOrderItem.self, database: .sqlite)
    migrations.add(model: FavouriteOrderItemAdditional.self, database: .sqlite)
    migrations.add(model: FavouriteCoffeeHouse.self, database: .sqlite)
    services.register(migrations)
}
