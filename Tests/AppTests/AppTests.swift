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
        
        let user: SignInTwoRequest = SignInTwoRequest(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: firstStepReply.sessionId)
        _ = try app.sendRequest(to: "signin", method: .POST, headers: headers, body: user)
        XCTAssert(true)
    }
    
    func testClient() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        _ = try app.sendRequest(to: "client", method: .GET, headers: headers, body: empty)
        XCTAssert(true)
    }
    
    func testClientSetPin() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let setPin1 = try app.sendRequest(to: "client/setPin", method: .GET, headers: headers, body: empty)
        let firstStepReply = try setPin1.content.decode(SetPinOneReply.self).wait()
        
        let crypto = "222222222"
        let pin = SetPinTwoRequest(crypto: crypto)
        let setPin2 = try app.sendRequest(to: "client/setPin", method: .POST, headers: headers, body: pin)
        XCTAssertEqual(setPin2.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testClientSetPhoto() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let photo = try app.sendRequest(to: "client/setPhoto", method: .PUT, headers: headers, body: empty)
        XCTAssertEqual(photo.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testPaycards() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
        
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let paycards = try app.sendRequest(to: "paycards", method: .GET, headers: headers, body: empty)
        _ = try paycards.content.decode([PaycardListReply].self).wait()
        XCTAssert(true)
    }
    
    func testPaycardAdd() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let setPin1 = try app.sendRequest(to: "paycard/add", method: .GET, headers: headers, body: empty)
        let firstStepReply = try setPin1.content.decode(SetPinOneReply.self).wait()
        
        let paycard = PaycardAddTwoRequest(type: "VISA", name: "Visa Elektron z Sercem", holderName: "Jan Nowak", numberCrypto: "asdasdasdasdasdasdasd", expired: "12/20", ccv2: "142")
        let paycardReq = try app.sendRequest(to: "paycard/add", method: .POST, headers: headers, body: paycard)
        XCTAssertEqual(paycardReq.http.status, HTTPStatus.ok)
        
        XCTAssert(true)
    }

    func testPaycardRemove() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let paycards = try app.sendRequest(to: "paycard/1", method: .DELETE, headers: headers, body: empty)
        XCTAssertEqual(paycards.http.status, .ok)
        XCTAssert(true)
    }

    func testOrders() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let orders = try app.sendRequest(to: "orders", method: .GET, headers: headers, body: empty)
        _ = try orders.content.decode([OrderListReply].self).wait()
        XCTAssert(true)
    }

    func testOrder() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        XCTAssert(true)
    }
    func testOrderStatus() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        XCTAssert(true)
    }
    
    func testOrderAddToFavourite() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        let test = [1]
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let coffeehouses = try app.sendRequest(to: "favouriteCoffeehouses", method: .POST, headers: headers, body: test)
        XCTAssertEqual(coffeehouses.http.status, HTTPStatus.ok)
        XCTAssert(true)
    }
    
    func testFavouriteOrders() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        XCTAssert(true)
    }
    
    func testFavouriteCoffehouses() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let coffeehouses = try app.sendRequest(to: "favouriteCoffeehouses", method: .GET, headers: headers, body: empty)
        _ = try coffeehouses.content.decode([Int].self).wait()
        XCTAssert(true)
    }
    
    func testPiggyUpdate() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        let empty: EmptyBody? = nil
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
        let piggies = try app.sendRequest(to: "piggy", method: .GET, headers: headers, body: empty)
        _ = try piggies.content.decode(PiggyBalanceReply.self).wait()
        XCTAssert(true)
    }
    
    func testPiggyBlock() throws {
        let sessionId = try app.signIn(appId: "fffae635-614e-27ca-bc20-f2e59f1b5bf3", crypto: "22222222")
        XCTAssertNotNil(sessionId)
    
        let block = PiggyUpdateRequest(balance: 10, balanceCurrency: "PLN")
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: sessionId!)
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
        ("testFavouriteCoffehouses", testFavouriteCoffehouses),
        ("testPiggyUpdate", testPiggyUpdate),
        ("testPiggyBlock", testPiggyBlock)
    ]
    
}
