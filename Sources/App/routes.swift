import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req in
        return "It works!"
    }
    
    let coffeeHouseController = CoffeeHouseController()
    router.get("coffeehouses", use: coffeeHouseController.index)
    router.get("coffeehouses", Int.parameter, "/locations", use: coffeeHouseController.location)
    router.get("coffeehouses", Int.parameter, "/menu", use: coffeeHouseController.menu)
    router.get("product", Int.parameter, use: coffeeHouseController.product)

    let userController = UserController()
    router.post("signup", use: userController.signup)
    router.get("signin", use: userController.signinpre)

    let sessionRouter = router.grouped(XSessionIdMiddleware())
    sessionRouter.post("signin", use: userController.signincom)

    let protectedRouter = router.grouped(UserMiddleware())
    protectedRouter.get("client", use: userController.client)
}
