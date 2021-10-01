//
//  UIAnimator.swift
//  Stocky
//
//  Created by Ankit Singh on 01/10/21.
//

import Foundation
import MBProgressHUD

protocol UIAnimator where  Self : UIViewController{
    func showLoadingAnimation()
    func hideLoadingAnimation()
}

extension UIAnimator {
    func showLoadingAnimation(){
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)

        }
    }
    func hideLoadingAnimation(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
