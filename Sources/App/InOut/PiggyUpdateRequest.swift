import Vapor


final class PiggyUpdateRequest: Content {
    
    var balance: Decimal
    var balanceCurrency: String
    
    init(balance: Decimal, balanceCurrency: String) {
        self.balance = balance
        self.balanceCurrency = balanceCurrency
    }
    
}
