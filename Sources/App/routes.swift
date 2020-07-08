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

    
    
    // Example of configuring a controller
   /* let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    */
}
