@testable import App
import Vapor
import XCTest


final class AppTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() {
        super.setUp()
        app = try! Application.testable()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testListOfCoffehouses() throws {
        let body: EmptyBody? = nil
        let test = try app.sendRequest(to: "coffeehouses", method: .GET, body: body)
        _ = try test.content.decode([CoffeeHouse].self).wait()
        XCTAssert(true)
    }

    func testListOfCoffehousesLocations() throws {
        let body: EmptyBody? = nil
        let test = try app.sendRequest(to: "coffeehouses/1/locations", method: .GET, body: body)
        _ = try test.content.decode([CoffeeHouseLocationReply].self).wait()
        XCTAssert(true)
    }
    
    func testCoffehousesMenu() throws {
        let body: EmptyBody? = nil
        let test = try app.sendRequest(to: "coffeehouses/1/menu", method: .GET, body: body)
        _ = try test.content.decode(CoffeeHouseMenuReply.self).wait()
        XCTAssert(true)
    }
    
    func testProductDetails() throws {
        let body: EmptyBody? = nil
        let test = try app.sendRequest(to: "product/1", method: .GET, body: body)
        _ = try test.content.decode(ProductReply.self).wait()
        XCTAssert(true)
    }
    
    func testSignup() throws {
        let body = SignUpRequest(fullName: "Jan Nowak", phoneNumber: "+48123345567", city: "Warszawa", birthDay: "2010-01-01", gender: "MALE")
        let test = try app.sendRequest(to: "signup", method: .POST, body: body)
        _ = try test.content.decode(SignUpReply.self).wait()
        XCTAssert(true)
    }
    
    func testSignin() throws {
        let empty: EmptyBody? = nil
        let test = try app.sendRequest(to: "signin", method: .GET, body: empty)
        let firstStepReply = try test.content.decode(SignInOneReply.self).wait()
        
        let crypto = try CryptoUtils.encodePin(pin: "1234", key: firstStepReply.transportKey, entrophy: firstStepReply.entrophy)
        let user: SignInTwoRequest = SignInTwoRequest(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: crypto ?? "")
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: firstStepReply.sessionId)
        _ = try app.sendRequest(to: "signin", method: .POST, headers: headers, body: user)
        XCTAssert(true)
    }
    
    func testClient() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        _ = try app.sendRequest(to: "client", method: .GET, headers: headers, body: empty)
        XCTAssert(true)
    }
    
    func testClientSetPin() throws {
        let (sessionId, transportKey) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let setPin1 = try app.sendRequest(to: "client/setPin", method: .GET, headers: headers, body: empty)
        let firstStepReply = try setPin1.content.decode(SetPinOneReply.self).wait()
            
        let crypto = try CryptoUtils.encodePin(pin: "1234", key: transportKey, entrophy: firstStepReply.entrophy) ?? ""
        XCTAssertFalse(crypto == "")

        let pin = SetPinTwoRequest(crypto: crypto)
        let setPin2 = try app.sendRequest(to: "client/setPin", method: .POST, headers: headers, body: pin)
        XCTAssertEqual(setPin2.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testClientSetPhoto() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let photo = try app.sendRequest(to: "client/setPhoto", method: .PUT, headers: headers, body: empty)
        XCTAssertEqual(photo.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testPaycards() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let paycards = try app.sendRequest(to: "paycards", method: .GET, headers: headers, body: empty)
        _ = try paycards.content.decode([PaycardListReply].self).wait()
        XCTAssert(true)
    }
    
    func testPaycardAdd() throws {
        let (sessionId, transportKey) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let setPin1 = try app.sendRequest(to: "paycard/add", method: .GET, headers: headers, body: empty)
        let firstStepReply = try setPin1.content.decode(SetPinOneReply.self).wait()
        
        let paycardNumberCrypto = try CryptoUtils.encodePaycardNumber(paycardNumber: "1234567890123456", key: transportKey, entrophy: firstStepReply.entrophy) ?? ""
        let paycard = PaycardAddTwoRequest(type: "VISA", name: "Visa Elektron z Sercem", holderName: "Jan Nowak", numberCrypto: paycardNumberCrypto, expired: "12/20", ccv2: "142")
        let paycardReq = try app.sendRequest(to: "paycard/add", method: .POST, headers: headers, body: paycard)
        XCTAssertEqual(paycardReq.http.status, HTTPStatus.ok)
        
        XCTAssert(true)
    }

    func testPaycardRemove() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let paycards = try app.sendRequest(to: "paycard/1", method: .DELETE, headers: headers, body: empty)
        XCTAssertEqual(paycards.http.status, .ok)
        XCTAssert(true)
    }

    func testOrders() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let orders = try app.sendRequest(to: "orders", method: .GET, headers: headers, body: empty)
        _ = try orders.content.decode([OrderListReply].self).wait()
        XCTAssert(true)
    }

    func testOrder() throws {
        let (sessionId, transportKey) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        var items = [OrderCreateItem]()
        items.append(OrderCreateItem(productId: 1, sizeId: 2, additionals: nil, count: 1))
        items.append(OrderCreateItem(productId: 2, sizeId: nil, additionals: [1], count: 1))

        let coffeehouseId = 1
        let localizationId = 1
        let paymentMethod = "BLIK"
        let currency = "PLN"
        let totalAmount = Decimal(12.50)
                
        let data = OrderCreatePreauthRequest(coffeehouseId: coffeehouseId, localizationId: localizationId, orderAsap: true, orderTime: nil, items: items, totalAmount: totalAmount, currency: currency, paymentMethod: paymentMethod, paycardId: nil)
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let order1 = try app.sendRequest(to: "order/preauth", method: .POST, headers: headers, body: data)
        let firstStepReply = try order1.content.decode(OrderCreatePreauthReply.self).wait()
        
        var itemsData = ""
        for item in items {
            itemsData += "\(item.productId)\(item.count)"
        }
        let pin = "1234"
        let dataToSecure = "\(coffeehouseId)\(localizationId)\(paymentMethod)\(currency)\(totalAmount)\(itemsData)\(pin)"
        let orderCrypto = try CryptoUtils.secureData(data: dataToSecure, key: transportKey, entrophy: firstStepReply.entrophy) ?? ""
        let orderData = OrderCreateCommitRequest(crypto: orderCrypto)
        let order2 = try app.sendRequest(to: "order/commit", method: .POST, headers: headers, body: orderData)
        let secondStepReply = try order2.content.decode(OrderCreateCommitReply.self).wait()
        XCTAssertTrue(secondStepReply.orderId.lengthOfBytes(using: .utf8) > 0)
        
        XCTAssert(true)
    }
    func testOrderStatus() throws {
        let (sessionId, transportKey) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let order = try app.sendRequest(to: "order/27d4-bcc-3e5-3c71/status", method: .GET, headers: headers, body: empty)
        XCTAssertTrue(order.http.status == HTTPStatus.notModified)
        XCTAssert(true)
    }
    
    func testOrderAddToFavourite() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let test = [1]
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let favourite = try app.sendRequest(to: "order/4cd3-0f1-1f8-b61d/addToFavourite", method: .POST, headers: headers, body: test)
        XCTAssertEqual(favourite.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testFavouriteOrders() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let orders = try app.sendRequest(to: "favouriteOrders", method: .GET, headers: headers, body: empty)
        _ = try orders.content.decode([FavouriteOrderListReply].self).wait()
        XCTAssert(true)
    }
    
    func testFavouriteOrderModify() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let data = FavouriteOrderModifyRequest(name: "Nowa ładna nazwa", orderAsap: nil, orderTime: nil)
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let order = try app.sendRequest(to: "favouriteOrder/1", method: .POST, headers: headers, body: data)
        XCTAssertEqual(order.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testFavouriteOrderRemove() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let order = try app.sendRequest(to: "favouriteOrder/3", method: .DELETE, headers: headers, body: empty)
        XCTAssertEqual(order.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testFavouriteCoffehouses() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let coffeehouses = try app.sendRequest(to: "favouriteCoffeehouses", method: .GET, headers: headers, body: empty)
        _ = try coffeehouses.content.decode([Int].self).wait()
        XCTAssert(true)
    }
    
    func testPiggyUpdate() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let piggies = try app.sendRequest(to: "piggy", method: .GET, headers: headers, body: empty)
        _ = try piggies.content.decode(PiggyBalanceReply.self).wait()
        XCTAssert(true)
    }
    
    func testPiggyBlock() throws {
        let (sessionId, _) = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", pin: "1234") ?? ("", "")
        XCTAssertTrue(sessionId.lengthOfBytes(using: .utf8) > 0)
    
        let block = PiggyUpdateRequest(balance: 10, balanceCurrency: "PLN")
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId)
        let piggies = try app.sendRequest(to: "piggy", method: .POST, headers: headers, body: block)
        XCTAssertEqual(piggies.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    static let allTests = [
        ("testListOfCoffehouses", testListOfCoffehouses),
        ("testListOfCoffehousesLocations", testListOfCoffehousesLocations),
        ("testCoffehousesMenu", testCoffehousesMenu),
        ("testProductDetails", testProductDetails),
        ("testSignup", testSignup),
        ("testSignin", testSignin),
        ("testClient", testClient),
        ("testClientSetPin", testClientSetPin),
        ("testClientSetPhoto", testClientSetPhoto),
        ("testPaycards", testPaycards),
        ("testPaycardAdd", testPaycardAdd),
        ("testPaycardRemove", testPaycardRemove),
        ("testOrders", testOrders),
        ("testOrder", testOrder),
        ("testOrderStatus", testOrderStatus),
        ("testOrderAddToFavourite", testOrderAddToFavourite),
        ("testFavouriteOrders", testFavouriteOrders),
        ("testFavouriteOrderModify", testFavouriteOrderModify),
        ("testFavouriteOrderRemove", testFavouriteOrderRemove),
        ("testFavouriteCoffehouses", testFavouriteCoffehouses),
        ("testPiggyUpdate", testPiggyUpdate),
        ("testPiggyBlock", testPiggyBlock)
    ]
    
}
