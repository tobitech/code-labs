//
//  String+Extensions.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
extension Character {
    fileprivate func isEmoji() -> Bool {
        return Character(UnicodeScalar(UInt32(0x1d000))!) <= self && self <= Character(UnicodeScalar(UInt32(0x1f77f))!)
            || Character(UnicodeScalar(UInt32(0x2100))!) <= self && self <= Character(UnicodeScalar(UInt32(0x26ff))!)
    }
}

    
extension String {
    func ranges(subString: String) -> [NSRange] {
        var ranges = [NSRange]()
        var range = NSRange(location: 0, length: count)
        while range.location != NSNotFound {
            range = (self as NSString).range(of: subString, options: .caseInsensitive, range: range)
            if range.location != NSNotFound {
                ranges.append(range)
                range = NSRange(location: range.location + range.length,
                                length: count - (range.location + range.length))
            }
        }
        return ranges
    }
    
    func decodeEmoj() -> String {
        let data = self.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII) ?? self
    }
    
    func encodeEmoj() -> String {
        let data = self.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    func stringByRemovingEmoji() -> String {
        return String(self.filter { !$0.isEmoji() })
    }
  
    public var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    public var isValidEmail: Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z]{1}[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        if emailTest.evaluate(with: self) {
            return !contains("..")
        }
        return false
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func encoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
    
    func removeWhiteSpace() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.whitespaces, options: .caseInsensitive, range: nil) == nil
    }
    
    func hasSpecialCharacters() -> Bool {
        let validString = CharacterSet(charactersIn: " !@#$%^&*()_+{}[]|\"<>,.~`/:;?=\\¥'£•¢")
        if let _ = self.rangeOfCharacter(from: validString) {
            return false
        } else{
            return true
        }
    }
    
    func hasNumbersAndEmoticon() -> Bool {
        
        if self.rangeOfCharacter(from: .letters) != nil || self == ""{
            return true
        }else {
            return false
        }
    }
    
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
    // substring -ing
    
    func substring(fromIndex : Int, count : Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: fromIndex)
        let endIndex = self.index(self.startIndex, offsetBy: fromIndex + count)
        let range = startIndex..<endIndex
        return String(self[range])
    }
    
    func toDouble() -> Double {
        let nsString = self as NSString
        return nsString.doubleValue
    }
}
