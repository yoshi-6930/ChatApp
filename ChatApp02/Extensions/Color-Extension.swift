//
//  Color-Extension.swift
//  ChatApp02
//
//  Created by 岩元喜輝 on 2020/07/08.
//  Copyright © 2020 Yoshiki Iwamoto. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
    
  
}

class ChangeColor{
      
      
      func changeColor(topR:CGFloat,topG:CGFloat,topB:CGFloat,topAlpha:CGFloat,
                       bottomR:CGFloat,bottomG:CGFloat,bottomB:CGFloat,bottomAlpha:CGFloat)->CAGradientLayer{
          
          //グラデーションの開始色
          let topColor = UIColor(red: topR, green: topG, blue: topB, alpha: topAlpha)
          
          let bottomColor = UIColor(red: bottomR, green:bottomG , blue: bottomB, alpha: bottomAlpha)
          
          
          let gradientColor = [topColor.cgColor,bottomColor.cgColor]
          
          let gradientLayer = CAGradientLayer()
          gradientLayer.colors = gradientColor
          return gradientLayer
      }
  }

