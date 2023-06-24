//
//  StartFunctions.swift
//  ArMap Pro
//
//  Created by Алексей Рубан on 22.05.2021.
//

import UIKit

class Start: NSObject {
    
    func figureOutLength() {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
            globalVariables.topScreenLength = window?.safeAreaInsets.top ?? 0.0
            globalVariables.bottomScreenLength = window?.safeAreaInsets.bottom ?? 0.0
        }
    }
    
}
