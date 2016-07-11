//
//  RootVC.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/8.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit



let headV:LogoView? = NSBundle.mainBundle().loadNibNamed("LogoView", owner: nil, options: nil)[0] as? LogoView


class RootVC: UITabBarController,UITabBarControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headV!.frame = CGRect(x: 0,y: 20,width: MAXW,height: 47)
        view.addSubview(headV!)
        self.delegate = self
    }

    
  
   
    internal func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool{

        switch Int( (self.viewControllers?.indexOf(viewController))! ) {
        case 0:
            self.tabBar.tintColor = ColorRGB(0, 122, 255)
        case 1:
            self.tabBar.tintColor = ColorRGB(255, 76, 76)
        case 2:
            self.tabBar.tintColor = ColorRGB(36, 209, 66)
        case 3:
            self.tabBar.tintColor = ColorRGB(205, 51, 255)
        default:
            break
        }
        return true
    }


}
