import Vapor


final class OrderController {

    func index(_ req: Request) throws -> Future<[OrderListReply]> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return Order.query(on: req).filter(\.userID, .equal, user.id ?? 0).all().flatMap { orders in
                    
                    var orderMaps: [Int: [OrderItem]] = [:]
                    var itemAdditionalMaps: [Int: [Int]] = [:]
                    
                    var subFutures: [EventLoopFuture<Void>] = []
                    let futures = try orders.map { order in
                        return try order.items.query(on: req).all().map(to: Void.self) { items in
                            orderMaps[order.id ?? 0] = items

                            for item in items {
                                subFutures.append(
                                    try item.additionals.query(on: req).all().map(to: Void.self) { additinalItems in
                                        var ids: [Int] = []
                                        var parentID: Int = 0
                                        for subItem in additinalItems {
                                            parentID = subItem.orderItemID
                                            ids.append(subItem.additionalID)
                                        }
                                        itemAdditionalMaps[parentID] = ids
                                        return
                                    }
                                )
                            }
 
                            return
                        }
                    }
                    
                    return EventLoopFuture<Void>.andAll(futures, eventLoop: req.eventLoop).flatMap(to: [OrderListReply].self) { _ in
                        return EventLoopFuture<Void>.andAll(subFutures, eventLoop: req.eventLoop).map(to: [OrderListReply].self) { _ in
                            var result: [OrderListReply] = []
                            for order in orders {
                                var items: [OrderItemReply] = []
                                for item in orderMaps[order.id ?? 0] ?? [] {
                                    items.append(OrderItemReply(productId: item.productID, sizeId: item.sizeID, additionals: itemAdditionalMaps[item.id ?? 0], count: item.count))
                                }
                                result.append(OrderListReply(orderId: order.orderId, coffeehouseId: order.coffeehouseID, localizationId: order.localizationID, orderAsap: order.orderAsap, orderTime: order.orderTime, items: items, totalAmount: order.totalAmount, currency: order.currency, paymentMethod: order.paymentMethod.rawValue, paycardId: order.paycardID, status: order.status.rawValue))
                            }
                            return result
                        }
                    }
                }
            }
        }
    }
    
    func addpre(_ req: Request) throws -> Future<OrderCreatePreauthReply> {
        let cache = try req.make(MySQLCache.self)
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        let entrophy = Session.randomTransportKey(length: 64)
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return try req.content.decode(OrderCreatePreauthRequest.self).flatMap { content in
                return cache.set("orderEntrophy-\(sessionId)", to: entrophy).flatMap { _ in
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(content)
                    return cache.set("orderDetails-\(sessionId)", to: data.base64EncodedString()).map {
                        return OrderCreatePreauthReply(entrophy: entrophy)
                    }
                }
            }
        }
    }
    
    func addcom(_ req: Request) throws -> Future<OrderCreateCommitReply> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return try req.content.decode(OrderCreateCommitRequest.self).flatMap { content in
                    let cache = try req.make(MySQLCache.self)
                    return cache.get("orderEntrophy-\(sessionId)", as: String.self).unwrap(or: Abort(.forbidden)).flatMap { entrophy in
                        return cache.get("orderDetails-\(sessionId)", as: String.self).unwrap(or: Abort(.forbidden)).flatMap { dataString in
                            guard let data = Data(base64Encoded: dataString) else { throw Abort(.forbidden) }
                            let decoder = JSONDecoder()
                            let order = try decoder.decode(OrderCreatePreauthRequest.self, from: data)
                            
                            var itemsData = ""
                            for item in order.items {
                                itemsData += "\(item.productId)\(item.count)"
                            }
                            let dataToSecure = "\(order.coffeehouseId)\(order.localizationId)\(order.paymentMethod)\(order.currency)\(order.totalAmount)\(itemsData)\(user.pin)"
                            
                            guard let unSecure = try CryptoUtils.unSecureData(encodedString: content.crypto, key: session.transportKey, entrophy: entrophy) else { throw Abort(.forbidden) }
                            guard dataToSecure == unSecure else { throw Abort(.forbidden) }
                            
                            let orderDB = Order(userID: user.id ?? 0, coffeehouseID: order.coffeehouseId, localizationID: order.localizationId, orderAsap: order.orderAsap, orderTime: order.orderTime, totalAmount: order.totalAmount, paymentMethod: PaymentMethodType(rawValue: order.paymentMethod) ?? .paycard, paycardID: order.paycardId)
                            
                            return orderDB.save(on: req).flatMap { createOrder in

                                var itemMaps: [Int: Int] = [:]
                                var futures = [EventLoopFuture<Void>]()
                                for (index, item) in order.items.enumerated() {
                                    let itemDB = OrderItem(orderID: createOrder.id ?? 0, productID: item.productId, sizeID: item.sizeId, count: item.productId)
                                    futures.append(itemDB.save(on: req).map(to: Void.self) { createOrderItem in
                                        itemMaps[index] = createOrderItem.id ?? 0
                                        return
                                    })
                                }
                                return EventLoopFuture<Void>.andAll(futures, eventLoop: req.eventLoop).flatMap { _ in
                                    var subFutures: [EventLoopFuture<Void>] = []
                                    for (index, item) in order.items.enumerated() {
                                        for additional in item.additionals ?? [] {
                                            let orderItemID = itemMaps[index] ?? 0
                                            let additionalDB = OrderItemAdditional(orderItemID: orderItemID, additionalID: additional)
                                            subFutures.append(additionalDB.save(on: req).map(to: Void.self) { _ in return })
                                        }
                                    }
                                    return EventLoopFuture<Void>.andAll(subFutures, eventLoop: req.eventLoop).map {
                                    _ in
                                        return OrderCreateCommitReply(orderId: createOrder.orderId)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func status(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                let orderID = try req.parameters.next(String.self)
                return Order.query(on: req).filter(\Order.orderId, .equal, orderID).first().unwrap(or: Abort(.conflict)).map { order in
                    switch order.status {
                        case .waiting:
                            return HTTPStatus.notModified
                        case .cancelled:
                            return HTTPStatus.resetContent
                        case .done:
                            return HTTPStatus.ok
                    }
                }
            }
        }
    }
    
    func addFavourite(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                let orderID = try req.parameters.next(String.self)
                return Order.query(on: req).filter(\Order.orderId, .equal, orderID).first().unwrap(or: Abort(.conflict)).flatMap { order in
                    guard order.status == .done else { throw Abort(.conflict) }
                    return try order.items.query(on: req).all().flatMap { items in
                        
                        var additionalMaps: [Int: [Int]] = [:]
                        var futures: [EventLoopFuture<Void>] = []
                        
                        for item in items {
                            futures.append(try item.additionals.query(on: req).all().map(to: Void.self) { additionals in
                                additionalMaps[item.id ?? 0] = additionals.map { add in
                                    return add.additionalID
                                }
                                return
                            })
                        }

                        return EventLoopFuture<Void>.andAll(futures, eventLoop: req.eventLoop).flatMap { _ in
                            let favOrder = FavouriteOrder(userID: order.userID, coffeehouseID: order.coffeehouseID, localizationID: order.localizationID, name: order.orderId, orderAsap: order.orderAsap, orderTime: order.orderTime, totalAmount: order.totalAmount, paymentMethod: order.paymentMethod, paycardID: order.paycardID)
                            return favOrder.save(on: req).flatMap { createFavOrder in
                                var itemMaps: [Int: Int] = [:]
                                var subFutures: [EventLoopFuture<Void>] = []
                                for (index, item) in items.enumerated() {
                                    let favOrderItem = FavouriteOrderItem(orderID: createFavOrder.id ?? 0, productID: item.productID, sizeID: item.sizeID, count: item.count)
                                    subFutures.append(favOrderItem.save(on: req).map(to: Void.self) { createItem in
                                        itemMaps[index] = createItem.id ?? 0
                                        return
                                    })
                                }
                                
                                return EventLoopFuture<Void>.andAll(subFutures, eventLoop: req.eventLoop).flatMap { _ in

                                    var subSubFutures: [EventLoopFuture<Void>] = []
                                    for (index, item) in items.enumerated() {
                                        if let itemId = itemMaps[index],
                                            let additionals = additionalMaps[item.id ?? 0] {
                                            for additional in additionals {
                                                let favOrderItemAdditional = FavouriteOrderItemAdditional(orderItemID: itemId, additionalID: additional)
                                                subSubFutures.append(favOrderItemAdditional.save(on: req).map(to: Void.self) { _ in return })
                                            }
                                        }
                                    }
                                    
                                    return EventLoopFuture<Void>.andAll(subSubFutures, eventLoop: req.eventLoop).map { _ in
                                        return HTTPStatus.ok
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func favourite(_ req: Request) throws -> Future<[FavouriteOrderListReply]> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return FavouriteOrder.query(on: req).filter(\.userID, .equal, user.id ?? 0).all().flatMap { orders in
                   
                   var orderMaps: [Int: [FavouriteOrderItem]] = [:]
                   var itemAdditionalMaps: [Int: [Int]] = [:]
                   
                   var subFutures: [EventLoopFuture<Void>] = []
                   let futures = try orders.map { order in
                       return try order.items.query(on: req).all().map(to: Void.self) { items in
                           orderMaps[order.id ?? 0] = items

                           for item in items {
                               subFutures.append(
                                   try item.additionals.query(on: req).all().map(to: Void.self) { additinalItems in
                                       var ids: [Int] = []
                                       var parentID: Int = 0
                                       for subItem in additinalItems {
                                           parentID = subItem.orderItemID
                                           ids.append(subItem.additionalID)
                                       }
                                       itemAdditionalMaps[parentID] = ids
                                       return
                                   }
                               )
                           }

                           return
                       }
                   }
                   
                   return EventLoopFuture<Void>.andAll(futures, eventLoop: req.eventLoop).flatMap(to: [FavouriteOrderListReply].self) { _ in
                       return EventLoopFuture<Void>.andAll(subFutures, eventLoop: req.eventLoop).map(to: [FavouriteOrderListReply].self) { _ in
                           var result: [FavouriteOrderListReply] = []
                           for order in orders {
                               var items: [OrderItemReply] = []
                               for item in orderMaps[order.id ?? 0] ?? [] {
                                   items.append(OrderItemReply(productId: item.productID, sizeId: item.sizeID, additionals: itemAdditionalMaps[item.id ?? 0], count: item.count))
                               }
                            result.append(FavouriteOrderListReply(favouriteOrderId: order.id ?? 0, name: order.name, coffeehouseId: order.coffeehouseID, localizationId: order.localizationID, orderAsap: order.orderAsap, orderTime: order.orderTime, items: items, totalAmount: order.totalAmount, currency: order.currency, paymentMethod: order.paymentMethod.rawValue, paycardId: order.paycardID))
                           }
                           return result
                       }
                   }
               }
           }
       }
    }
    
    func modifyFavourite(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        let favouriteId = try req.parameters.next(Int.self)
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return FavouriteOrder.find(favouriteId, on: req).unwrap(or: Abort(.conflict)).flatMap { order in
                    return try req.content.decode(FavouriteOrderModifyRequest.self).flatMap { content in
                        if let newName = content.name {
                            order.name = newName
                        }
                        if let newAsap = content.orderAsap {
                            order.orderAsap = newAsap
                            order.orderTime = content.orderTime
                        }
                        return order.save(on: req).map { _ in
                            return HTTPStatus.ok
                        }
                    }
                }
            }
        }
    }
    
    func deleteFavourite(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        let favouriteId = try req.parameters.next(Int.self)
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return FavouriteOrder.find(favouriteId, on: req).unwrap(or: Abort(.conflict)).flatMap { order in
                    return try order.items.query(on: req).all().flatMap { items in

                        var futures: [EventLoopFuture<Void>] = []
                        var subFutures: [EventLoopFuture<Void>] = []
                        var subSubFutures: [EventLoopFuture<Void>] = []
                        
                        for item in items {
                            futures.append( try item.additionals.query(on: req).all().map(to: Void.self) { additinalItems in
                                for additional in additinalItems {
                                    subSubFutures.append( additional.delete(on: req).map(to: Void.self) { _ in return } )
                                }
                                subFutures.append( item.delete(on: req).map(to: Void.self) { _ in return } )
                            } )
                        }

                        return EventLoopFuture<Void>.andAll(futures, eventLoop: req.eventLoop).flatMap { _ in
                            return EventLoopFuture<Void>.andAll(subSubFutures, eventLoop: req.eventLoop).flatMap { _ in
                                return EventLoopFuture<Void>.andAll(subFutures, eventLoop: req.eventLoop).flatMap { _ in
                                    return order.delete(on: req).map { _ in
                                        return HTTPStatus.ok
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
    }
    
    
    
    func doneAllWaitingOrder(_ req: Request) throws -> Future<HTTPStatus> {
        return req.withPooledConnection(to: .mysql) { conn in
            let statusWaiting = "{\"rawValue\": \"WAITING\"}"
            let statusDone = "{\"rawValue\": \"DONE\"}"
            return conn.raw("UPDATE ORDER SET status='\(statusDone)' WHERE status='\(statusWaiting)'").all().map { _ in
                return HTTPStatus.ok
            }
        }
    }
    
    func cancelWaitingOrder(_ req: Request) throws -> Future<HTTPStatus> {
        let orderId = try req.parameters.next(String.self)
        return Order.query(on: req).filter(\.orderId, .equal, orderId).first().unwrap(or: Abort(.conflict)).flatMap { order in
            guard order.status == .waiting else { throw Abort(.forbidden) }
            order.status = .cancelled
            return order.save(on: req).map { _ in
                return HTTPStatus.ok
            }
        }
    }

}


