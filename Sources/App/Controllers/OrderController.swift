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
    
    func addpre(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func addcom(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func status(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func addFavourite(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func favourite(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func modifyFavourite(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    
}
