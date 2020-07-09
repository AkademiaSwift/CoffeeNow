import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req in
        return "It works!"
    }
    
    let coffeeHouseController = CoffeeHouseController()
    router.get("coffeehouses", use: coffeeHouseController.index)
    router.get("coffeehouses", Int.parameter, "locations", use: coffeeHouseController.location)
    router.get("coffeehouses", Int.parameter, "menu", use: coffeeHouseController.menu)
    router.get("product", Int.parameter, use: coffeeHouseController.product)

    let userController = UserController()
    router.post("signup", use: userController.signup)
    router.get("signin", use: userController.signinpre)

    let sessionRouter = router.grouped(XSessionIdMiddleware())
    sessionRouter.post("signin", use: userController.signincom)

    let protectedRouter = router.grouped(UserMiddleware())
    protectedRouter.get("client", use: userController.client)
    
    protectedRouter.get("client/setPin", use: userController.setpinpre)
    protectedRouter.post("client/setPin", use: userController.setpincom)
    protectedRouter.put("client/setPhoto", use: userController.setphoto)
    
    let piggyController = PiggyController()
    protectedRouter.get("piggy", use: piggyController.getBalance)
    protectedRouter.post("piggy", use: piggyController.updateBalance)
    
    let paycardController = PaycardController()
    protectedRouter.get("paycards", use: paycardController.index)
    protectedRouter.get("paycard/add", use: paycardController.addpre)
    protectedRouter.post("paycard/add", use: paycardController.addcom)
    protectedRouter.delete("paycard", Paycard.parameter, use: paycardController.delete)
    
    protectedRouter.get("favouriteCoffeehouses", use: coffeeHouseController.favourite)
    protectedRouter.post("favouriteCoffeehouses", use: coffeeHouseController.modifyFavourite)

    let orderController = OrderController()
    protectedRouter.get("orders", use: orderController.index)
    protectedRouter.post("order/preauth", use: orderController.addpre)
    protectedRouter.post("order/commit", use: orderController.addcom)
    protectedRouter.get("order", Int.parameter, "status", use: orderController.status)
    protectedRouter.post("order", Int.parameter, "addToFavourite", use: orderController.addFavourite)
    protectedRouter.get("favouriteOrders", use: orderController.favourite)
    protectedRouter.delete("favouriteOrder", Int.parameter, use: orderController.modifyFavourite)
    
}
