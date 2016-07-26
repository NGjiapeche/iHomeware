//
//  GlobalShare.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/11.
//  Copyright © 2016年 mac. All rights reserved.
//

import Foundation
import UIKit

let MAXW = UIScreen.mainScreen().bounds.size.width
let MAXH = UIScreen.mainScreen().bounds.size.height

func ColorRGB(red: Double,_ green: Double,_ blue: Double) -> UIColor {
    return UIColor(red: CGFloat(red/256.0) ,  green: CGFloat(green/256),  blue: CGFloat(blue/256), alpha:1)
}

extension UIViewController{
    func hideHeadBar()  {
        self.navigationController?.navigationBar.hidden = true
    }
}


let dateFormatter :NSDateFormatter = {
    let dateFormatter1 = NSDateFormatter()
    dateFormatter1.locale = NSLocale.currentLocale()
    dateFormatter1.dateFormat = "yyyy HH:mm:ss.SSS"
    return dateFormatter1
}()
func printLog<T>(message: T,
              file: String = #file,
              method: String = #function,
              line: Int = #line)
{
    let currentDate = NSDate()
    let olddatestr = dateFormatter.stringFromDate(currentDate)
    #if DEBUG
        print("\(olddatestr) : \((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        
    #else
        
    #endif
}

//MARK - 正则表达式
struct RegexHelper {
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern,
                                        options: .CaseInsensitive)
    }
    
    func match(input: String) -> Bool {
        let matches = regex.matchesInString(input,
                                            options: [],
                                            range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
}
let emailPattern =
"^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"

infix operator =~ {
associativity none
precedence 130
}

func =~(lhs: String, rhs: String) -> Bool {
    do {
        return try RegexHelper(rhs).match(lhs)
    } catch _ {
        return false
    }
}