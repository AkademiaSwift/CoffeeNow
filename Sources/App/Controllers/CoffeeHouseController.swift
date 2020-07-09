import Vapor


final class CoffeeHouseController {

    func index(_ req: Request) throws -> Future<[CoffeeHouse]> {
        return CoffeeHouse.query(on: req).all()
    }

    func location(_ req: Request) throws -> Future<[CoffeeHouseLocationReply]> {
        let coffeeHouseID = try req.parameters.next(Int.self)
        return CoffeeHouse.find(coffeeHouseID, on: req).unwrap(or: Abort(.conflict)).flatMap { coffeeHouse in
            return try coffeeHouse.locations.query(on: req).all().flatMap(to: [CoffeeHouseLocationReply].self) { locations in
                return Future.map(on: req) { return locations.map { return CoffeeHouseLocationReply(location: $0) }
                }
            }
        }
    }
    
    func menu(_ req: Request) throws -> Future<CoffeeHouseMenuReply> {
        let coffeeHouseID = try req.parameters.next(Int.self)
        
        let logger = try req.make(Logger.self)
        logger.info("Logger created!")
        
        return CoffeeHouse.find(coffeeHouseID, on: req).unwrap(or: Abort(.notFound)).flatMap { coffeeHouse in
            return try coffeeHouse.menus.query(on: req).all().flatMap(to: CoffeeHouseMenuReply.self) { menuCategories in

                var productMaps: [Int: [Product]] = [:]
                var additionalMaps: [Int: [ProductAdditionalReply]] = [:]
                var sizeMaps: [Int: [ProductSizeReply]] = [:]
                var ingredientMaps: [Int: [ProductIngredientReply]] = [:]
                var subFutures: [EventLoopFuture<Void>] = []
                
                let futures = try menuCategories.map { menuCategory in
                    return try menuCategory.products.query(on: req).all().map(to: Void.self) { products in
                        productMaps[menuCategory.id ?? 0] = products
                        
                        let additionalfutures = try products.map { product in
                            return try product.additionals.query(on: req).all().map(to: Void.self) { additionals in
                                additionalMaps[product.id ?? 0] = additionals.map { addintional in
                                    return ProductAdditionalReply(id: addintional.id ?? 0, name: addintional.name, price: addintional.price, currency: addintional.currency)
                                }
                                return
                            }
                        }
                        let sizefutures = try products.map { product in
                            return try product.sizes.query(on: req).all().map(to: Void.self) { sizes in
                                sizeMaps[product.id ?? 0] = sizes.map { size in
                                    return ProductSizeReply(id: size.id ?? 0, name: size.name, price: size.price, currency: size.currency)
                                }
                                return
                            }
                        }
                        let ingredientfutures = try products.map { product in
                            return try product.ingredients.query(on: req).all().map(to: Void.self) { ingredients in
                                ingredientMaps[product.id ?? 0] = ingredients.map { ingredient in
                                    return ProductIngredientReply(name: ingredient.name, color: ingredient.color)
                                }
                                return
                            }
                        }
                        
                        subFutures += additionalfutures + sizefutures + ingredientfutures
                        return
                    }
                }
                
                return EventLoopFuture<Void>.andAll(futures, eventLoop: req.eventLoop).flatMap(to: CoffeeHouseMenuReply.self) { _ in
                    return EventLoopFuture<Void>.andAll(subFutures, eventLoop: req.eventLoop).map(to: CoffeeHouseMenuReply.self) {
                        _ in
                        
                        var cats: [CoffeeHouseMenu] = []
                        for menuCategory in menuCategories {
                            let productDB: [Product] = productMaps[menuCategory.id ?? 0] ?? []
                            let products = productDB.map { product in
                                return ProductShortReply(id: product.id ?? 0, name: product.name, photoUrl: product.photoUrl, shortDescription: product.shortDescription, ingredients: ingredientMaps[product.id ?? 0] ?? [], sizes: sizeMaps[product.id ?? 0] ?? [], additionals: additionalMaps[product.id ?? 0] ?? [])
                            }
                            cats.append(CoffeeHouseMenu(id: menuCategory.id ?? 0, name: menuCategory.name, products: products))
                        }
                        return CoffeeHouseMenuReply(categories: cats)

                    }
                }
            }
        }
    }
    
    func product(_ req: Request) throws -> Future<ProductReply> {
        let productID = try req.parameters.next(Int.self)
        return Product.find(productID, on: req).unwrap(or: Abort(.notFound)).flatMap { product in
            return try product.ingredientDescriptions.query(on: req).all().map(to: ProductReply.self) { ingredients in
                return ProductReply(product: product, ingredients: ingredients)
            }
        }
    }
    
    func favourite(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    
    func modifyFavourite(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
}
