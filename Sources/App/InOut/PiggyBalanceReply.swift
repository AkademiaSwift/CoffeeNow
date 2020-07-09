import Vapor


final class PiggyBalanceReply: Content {
    
    var balance: Decimal
    var balanceCurrency: String
    var lastUpdate: Date
    
    init(balance: Decimal, balanceCurrency: String, lastUpdate: Date) {
        self.balance = balance
        self.balanceCurrency = balanceCurrency
        self.lastUpdate = lastUpdate
    }
    
}
