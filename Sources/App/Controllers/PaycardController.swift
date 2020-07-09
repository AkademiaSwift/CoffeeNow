import Vapor


final class PaycardController {

    func index(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func addpre(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func addcom(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
    }
    func delete(_ req: Request) throws -> HTTPStatus {
        return HTTPStatus.ok
        /*
         return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
         */
    }

}
