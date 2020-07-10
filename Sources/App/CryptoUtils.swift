import Vapor
import Crypto

class CryptoUtils {
    
    static func encodePin(pin: String, key: String, entrophy: String) throws -> String? {
        guard pin.lengthOfBytes(using: .utf8) == 4 else { return nil }
        guard key.lengthOfBytes(using: .utf8) == 48 else { return nil }
        guard entrophy.lengthOfBytes(using: .utf8) == 64 else { return nil }
        
        var pinEntrophyArr: Array<Character> = []
        let pinArr = Array(pin)
        for (index, item) in entrophy.enumerated() {
            switch index {
                case 8:
                    pinEntrophyArr.append(pinArr[0])
                    pinEntrophyArr.append(item)
                case 21:
                    pinEntrophyArr.append(pinArr[1])
                    pinEntrophyArr.append(item)
                case 38:
                    pinEntrophyArr.append(pinArr[2])
                    pinEntrophyArr.append(item)
                case 50:
                    pinEntrophyArr.append(pinArr[3])
                    pinEntrophyArr.append(item)
                default:
                    pinEntrophyArr.append(item)
            }
        }
        let pinEntrophied = String(pinEntrophyArr)

        let aes256 = Cipher(algorithm: .aes256cbc)
        guard let allKeyData = key.data(using: .utf8), let dataToEncrypt = pinEntrophied.data(using: .utf8) else { return nil }
        let aesKey = allKeyData.subdata(in: 0..<32)
        let aesIv = allKeyData.subdata(in: 32..<48)
        //print(allKeyData.hexDebug)
        //print(aesKey.hexDebug)
        //print(aesIv.hexDebug)
        try aes256.reset(key: aesKey, iv: aesIv, mode: .encrypt)
        var buffer = Data()
        try aes256.update(data: dataToEncrypt, into: &buffer)
        try aes256.finish(into: &buffer)
        return buffer.base64EncodedString()
    }
    
    static func decodePin(encodedString: String, key: String, entrophy: String) throws -> String? {
        guard encodedString.lengthOfBytes(using: .utf8) > 0 else { return nil }
        guard key.lengthOfBytes(using: .utf8) == 48 else { return nil }
        guard entrophy.lengthOfBytes(using: .utf8) == 64 else { return nil }
        
        let aes256 = Cipher(algorithm: .aes256cbc)
        guard let allKeyData = key.data(using: .utf8), let dataToDecrypt = Data(base64Encoded: encodedString) else { return nil }
        let aesKey = allKeyData.subdata(in: 0..<32)
        let aesIv = allKeyData.subdata(in: 32..<48)
        //print(allKeyData.hexDebug)
        //print(aesKey.hexDebug)
        //print(aesIv.hexDebug)
        try aes256.reset(key: aesKey, iv: aesIv, mode: .decrypt)
        var buffer = Data()
        try aes256.update(data: dataToDecrypt, into: &buffer)
        try aes256.finish(into: &buffer)
        guard let pinEntrophied = String(data: buffer, encoding: .utf8), pinEntrophied.lengthOfBytes(using: .utf8) == 68 else { return nil }
        
        var pinEntrophyArr: Array<Character> = []
        var entrophyArr: Array<Character> = []
        for (index, item) in pinEntrophied.enumerated() {
            switch index {
                case 8:
                    pinEntrophyArr.append(item)
                case 22:
                    pinEntrophyArr.append(item)
                case 40:
                    pinEntrophyArr.append(item)
                case 53:
                    pinEntrophyArr.append(item)
                default:
                    entrophyArr.append(item)
            }
        }
        let pin = String(pinEntrophyArr)
        let entrophyDecoded = String(entrophyArr)
        
        guard entrophyDecoded == entrophy else { return nil }
        return pin
    }

    static func encodePaycardNumber(paycardNumber: String, key: String, entrophy: String) throws -> String? {
        guard paycardNumber.lengthOfBytes(using: .utf8) == 15 || paycardNumber.lengthOfBytes(using: .utf8) == 16 else { return nil }
        guard key.lengthOfBytes(using: .utf8) == 48 else { return nil }
        guard entrophy.lengthOfBytes(using: .utf8) == 64 else { return nil }
        
        var paycardNumberArr: Array<Character> = []
        let pinArr = Array(paycardNumber)
        for (index, item) in entrophy.enumerated() {
            switch index {
                case 3:
                    paycardNumberArr.append(pinArr[0])
                    paycardNumberArr.append(item)
                case 7:
                    paycardNumberArr.append(pinArr[1])
                    paycardNumberArr.append(item)
                case 9:
                    paycardNumberArr.append(pinArr[2])
                    paycardNumberArr.append(item)
                case 12:
                    paycardNumberArr.append(pinArr[3])
                    paycardNumberArr.append(item)
                case 14:
                    paycardNumberArr.append(pinArr[4])
                    paycardNumberArr.append(item)
                case 18:
                    paycardNumberArr.append(pinArr[5])
                    paycardNumberArr.append(item)
                case 22:
                    paycardNumberArr.append(pinArr[6])
                    paycardNumberArr.append(item)
                case 25:
                    paycardNumberArr.append(pinArr[7])
                    paycardNumberArr.append(item)
                case 29:
                    paycardNumberArr.append(pinArr[8])
                    paycardNumberArr.append(item)
                case 31:
                    paycardNumberArr.append(pinArr[9])
                    paycardNumberArr.append(item)
                case 36:
                    paycardNumberArr.append(pinArr[10])
                    paycardNumberArr.append(item)
                case 40:
                    paycardNumberArr.append(pinArr[11])
                    paycardNumberArr.append(item)
                case 43:
                    paycardNumberArr.append(pinArr[12])
                    paycardNumberArr.append(item)
                case 47:
                    paycardNumberArr.append(pinArr[13])
                    paycardNumberArr.append(item)
                case 53:
                    paycardNumberArr.append(pinArr[14])
                    paycardNumberArr.append(item)
                case 59:
                    if paycardNumber.lengthOfBytes(using: .utf8) == 15 {
                        paycardNumberArr.append("W")
                    } else {
                        paycardNumberArr.append(pinArr[15])
                    }
                    paycardNumberArr.append(item)
                default:
                    paycardNumberArr.append(item)
            }
        }
        let paycardNumberEntrophied = String(paycardNumberArr)
        
        let aes256 = Cipher(algorithm: .aes256cbc)
        guard let allKeyData = key.data(using: .utf8), let dataToEncrypt = paycardNumberEntrophied.data(using: .utf8) else { return nil }
        let aesKey = allKeyData.subdata(in: 0..<32)
        let aesIv = allKeyData.subdata(in: 32..<48)
        //print(allKeyData.hexDebug)
        //print(aesKey.hexDebug)
        //print(aesIv.hexDebug)
        try aes256.reset(key: aesKey, iv: aesIv, mode: .encrypt)
        var buffer = Data()
        try aes256.update(data: dataToEncrypt, into: &buffer)
        try aes256.finish(into: &buffer)
        return buffer.base64EncodedString()
    }
    
    static func decodePaycardNumber(encodedString: String, key: String, entrophy: String) throws -> String? {
        guard encodedString.lengthOfBytes(using: .utf8) > 0 else { return nil }
        guard key.lengthOfBytes(using: .utf8) == 48 else { return nil }
        guard entrophy.lengthOfBytes(using: .utf8) == 64 else { return nil }
        
        let aes256 = Cipher(algorithm: .aes256cbc)
        guard let allKeyData = key.data(using: .utf8), let dataToDecrypt = Data(base64Encoded: encodedString) else { return nil }
        let aesKey = allKeyData.subdata(in: 0..<32)
        let aesIv = allKeyData.subdata(in: 32..<48)
        //print(allKeyData.hexDebug)
        //print(aesKey.hexDebug)
        //print(aesIv.hexDebug)
        try aes256.reset(key: aesKey, iv: aesIv, mode: .decrypt)
        var buffer = Data()
        try aes256.update(data: dataToDecrypt, into: &buffer)
        try aes256.finish(into: &buffer)
        guard let paycardNumberEntrophied = String(data: buffer, encoding: .utf8),
            paycardNumberEntrophied.lengthOfBytes(using: .utf8) == 80 else { return nil }

        var paycardNumberEntrophyArr: Array<Character> = []
        var entrophyArr: Array<Character> = []
        for (index, item) in paycardNumberEntrophied.enumerated() {
            switch index {
                case 3:
                    paycardNumberEntrophyArr.append(item)
                case 8:
                    paycardNumberEntrophyArr.append(item)
                case 11:
                    paycardNumberEntrophyArr.append(item)
                case 15:
                    paycardNumberEntrophyArr.append(item)
                case 18:
                    paycardNumberEntrophyArr.append(item)
                case 23:
                    paycardNumberEntrophyArr.append(item)
                case 28:
                    paycardNumberEntrophyArr.append(item)
                case 32:
                    paycardNumberEntrophyArr.append(item)
                case 37:
                    paycardNumberEntrophyArr.append(item)
                case 40:
                    paycardNumberEntrophyArr.append(item)
                case 46:
                    paycardNumberEntrophyArr.append(item)
                case 51:
                    paycardNumberEntrophyArr.append(item)
                case 55:
                    paycardNumberEntrophyArr.append(item)
                case 60:
                    paycardNumberEntrophyArr.append(item)
                case 67:
                    paycardNumberEntrophyArr.append(item)
                case 74:
                    if item != "W" {
                        paycardNumberEntrophyArr.append(item)
                    }
                default:
                    entrophyArr.append(item)
            }
        }
        let paycardNumber = String(paycardNumberEntrophyArr)
        let entrophyDecoded = String(entrophyArr)
        
        guard entrophyDecoded == entrophy else { return nil }
        return paycardNumber
    }

    static func secureData(data: String, key: String, entrophy: String) throws -> String? {
        guard data.lengthOfBytes(using: .utf8) > 0 else { return nil }
        guard key.lengthOfBytes(using: .utf8) == 48 else { return nil }
        guard entrophy.lengthOfBytes(using: .utf8) == 64 else { return nil }
        
        let encodedString = "\(entrophy)\(data)"
       
        let aes256 = Cipher(algorithm: .aes256cbc)
        guard let allKeyData = key.data(using: .utf8), let dataToEncrypt = encodedString.data(using: .utf8) else { return nil }
        let aesKey = allKeyData.subdata(in: 0..<32)
        let aesIv = allKeyData.subdata(in: 32..<48)
        //print(allKeyData.hexDebug)
        //print(aesKey.hexDebug)
        //print(aesIv.hexDebug)
        try aes256.reset(key: aesKey, iv: aesIv, mode: .encrypt)
        var buffer = Data()
        try aes256.update(data: dataToEncrypt, into: &buffer)
        try aes256.finish(into: &buffer)
        return buffer.base64EncodedString()
    }
    
    static func unSecureData(encodedString: String, key: String, entrophy: String) throws -> String? {
        guard encodedString.lengthOfBytes(using: .utf8) > 0 else { return nil }
        guard key.lengthOfBytes(using: .utf8) == 48 else { return nil }
        guard entrophy.lengthOfBytes(using: .utf8) == 64 else { return nil }
        
        let aes256 = Cipher(algorithm: .aes256cbc)
        guard let allKeyData = key.data(using: .utf8), let dataToDecrypt = Data(base64Encoded: encodedString) else { return nil }
        let aesKey = allKeyData.subdata(in: 0..<32)
        let aesIv = allKeyData.subdata(in: 32..<48)
        //print(allKeyData.hexDebug)
        //print(aesKey.hexDebug)
        //print(aesIv.hexDebug)
        try aes256.reset(key: aesKey, iv: aesIv, mode: .decrypt)
        var buffer = Data()
        try aes256.update(data: dataToDecrypt, into: &buffer)
        try aes256.finish(into: &buffer)
        guard let unSecured = String(data: buffer, encoding: .utf8),
           unSecured.lengthOfBytes(using: .utf8) > 64 else { return nil }
        let index = unSecured.index(unSecured.startIndex, offsetBy: 64)
        let entrophyDecoded = String(unSecured[..<index])
        let data = String(unSecured[index...])
        guard entrophyDecoded == entrophy else { return nil }
        return data
    }

}
