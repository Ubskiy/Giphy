//
//  AlertPresenter.swift
//  Giphy
//
//  Created by Арсений Убский on 16.01.2023.
//

import UIKit
protocol ViewControllerProtocol: AnyObject {
    func present(alert: UIAlertController, animated: Bool, completion: ()->Void)
}

struct AlertPresenter: AlertPresenterProtocol {
    weak private var viewController: UIViewController?
    //иньектируем viewController через инициализатор
    init(viewController: UIViewController?){
        self.viewController = viewController
    }
    
    func show(results:AlertModel) {
        let alert = UIAlertController(title: results.title,
                                      message: results.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: results.buttonText, style: .default, handler: { _ in
            results.completion()
        })
        alert.view.accessibilityIdentifier = "Game results"
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
