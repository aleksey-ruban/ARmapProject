//
//  HighlightView.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 29.05.2021.
//

import UIKit

class HighlightView: UIView {
    
    var normalOpacity: CGFloat = 1.0
    var isMainScreenButtons: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async {
            //self.layer.opacity = self.normalOpacity
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                //self.layer.opacity = 0.5
                if self.isMainScreenButtons {
                    self.backgroundColor = UIColor(named: "mainScreenButtonsDarken")
                } else {
                    self.backgroundColor = UIColor(named: "infoDarken")
                }
            }, completion: nil)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            //self.layer.opacity = 0.5
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations:{
                //self.layer.opacity = self.normalOpacity
                if self.isMainScreenButtons {
                    self.backgroundColor = UIColor(named: "mainScreenButtons")
                } else {
                    self.backgroundColor = UIColor(named: "infoColor")
                }
            }, completion: nil)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        DispatchQueue.main.async {
            //self.layer.opacity = 0.5
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                //self.layer.opacity = self.normalOpacity
                if self.isMainScreenButtons {
                    self.backgroundColor = UIColor(named: "mainScreenButtons")
                } else {
                    self.backgroundColor = UIColor(named: "infoColor")
                }
            }, completion: nil)
        }
    }
}
