import Vapor


final class CoffeeHouseController {

    func index(_ req: Request) throws -> Future<[CoffeeHouse]> {
        return CoffeeHouse.query(on: req).all()
    }

}
