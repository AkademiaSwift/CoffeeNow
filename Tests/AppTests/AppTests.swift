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
    }
    
    

    static let allTests = [
        ("testListOfCoffehouses", testListOfCoffehouses),
        ("testListOfCoffehousesLocations", testListOfCoffehousesLocations),
        ("testCoffehousesMenu", testCoffehousesMenu),
        ("testProductDetails", testProductDetails),
        ("testSignup", testSignup),
        ("testSignin", testSignin)
        
    ]
    
    
}
