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

func printLog<T>(message: T,
              file: String = #file,
              method: String = #function,
              line: Int = #line)
{
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        
    #else
        
    #endif
}