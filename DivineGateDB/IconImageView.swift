//
//  IconImageView.swift
//  DivineGateDB
//
//  Created by 松本拓真 on 2016/02/04.
//  Copyright © 2016年 TakumaMatsumoto. All rights reserved.
//

import UIKit

class IconImageView: UIImageView {
    
    var number: Int!
    
    func commonInit() {
        self.image = UIImage(named: ImageName().emptyImageName)
        self.tag = TouchTag().iconTag
        self.number = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func setIcon(number: Int, touchable: Bool) {
        if number >= 1 {
            let imageName = NSString(format: "%03d-icon", number) as String
            if let icon = UIImage(named: imageName) {
                self.image = icon
            } else {
                self.image = UIImage(named: ImageName().emptyImageName)
            }
            self.number = number
        }
        self.userInteractionEnabled = touchable
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UIApplication.sharedApplication().sendAction("iconTapped:", to: nil, from: self, forEvent: nil)
    }

}
