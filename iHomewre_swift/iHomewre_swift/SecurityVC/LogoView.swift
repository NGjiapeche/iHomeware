//
//  LogoView.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/11.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit

class  LogoView: UIView {

    @IBOutlet weak var leftbut: UIButton!
    @IBOutlet weak var rightbut: UIButton!
    @IBOutlet weak var titlelab: UILabel!
    @IBOutlet weak var logoimgv: UIImageView!
    
    var backLeftButtonTapped: (() -> Void)?
    var backRightButtonTapped: (() -> Void)?
    
    override func drawRect(rect: CGRect) {
        
    }

    
    func resetUI(newLeftButImg: String?, _ title: String, _ rightButImg: String?, _ logohide: Bool){
        titlelab.text = title
        logoimgv.hidden = logohide
        addTapEventHandler()
        
        guard  let str1 = newLeftButImg,str2 = rightButImg else { return }
            
        leftbut.setImage(UIImage(named: str1), forState: .Normal)
        rightbut.setImage(UIImage(named: str2), forState: .Normal)
        

    }
    
    private func addTapEventHandler() {
        leftbut.addTarget(self, action: #selector(LogoView.backLeftButtonDidTouch(_:)), forControlEvents: .TouchUpInside)
        rightbut.addTarget(self, action: #selector(LogoView.backRightButtonDidTouch(_:)), forControlEvents: .TouchUpInside)
    }
    
    func backLeftButtonDidTouch(sender: UIGestureRecognizer) {
        backLeftButtonTapped?()
    }
    
    func backRightButtonDidTouch(sender: UIGestureRecognizer) {
        backRightButtonTapped?()
    }
    
}
