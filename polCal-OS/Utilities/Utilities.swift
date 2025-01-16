//
//  Utilities.swift
//  polCal
//
//  Created by Lukas on 28/08/2024.
//

//this was taken from https://www.youtube.com/watch?v=mdQcqPq9Kl4
//the original code is from: https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
//maybe ask chatGPT how to fix this if it ever becomes a problem, but if it works don't touch it!

//fixed the earlier error message via chatGPT

import Foundation
import UIKit

final class Utilities {

    static let shared = Utilities()

    private init() {}

    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        let controller = controller ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }?.rootViewController

        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
