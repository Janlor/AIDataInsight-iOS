//
//  NormalAlertController.swift
//  Pods
//
//  Created by Janlor on 4/22/26.
//

import UIKit

/// # Custom Alert View Controller
/// This view controller presents a custom alert with a title, subtitle, and customizable buttons.
///
/// - Parameters:
///   - `title`: The title of the alert.
///   - `subTitle`: The subtitle of the alert.
///   - `buttonModels`: An array of `AlertButtonModel` that describes the buttons to display.
///
/// ```
// let alertVC = NormalAlertController(
//     title: "Alert Title",
//     subTitle: "This is a subtitle of the alert which provides more details.",
//     buttonModels: [
//         AlertButtonModel(title: "Cancel", type: .cancel, action: { appLog("Cancel tapped") }),
//         AlertButtonModel(title: "OK", type: .confirm, action: { appLog("OK tapped") }),
//         AlertButtonModel(title: "Delete", type: .destructive, action: { appLog("Delete tapped") })
//     ]
// )
// present(alertVC, animated: false, completion: nil)
/// ```
public class NormalAlertController: UIViewController {
    
    // MARK: - UI Elements
    
    private var alertView: NormalAlertView!
    
    // MARK: - Initialization
    
    /// Initializes the custom alert view controller.
    ///
    /// - Parameters:
    ///   - `title`: The title of the alert.
    ///   - `subTitle`: The subtitle of the alert.
    ///   - `buttonModels`: An array of `AlertButtonModel` that describes the buttons to display.
    public init(title: String?, subTitle: String?, buttonModels: [AlertButtonModel]) {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        
        alertView = NormalAlertView(title: title, subTitle: subTitle, buttonModels: buttonModels)
        alertView.didDismissed = {
            self.dismiss(animated: false, completion: nil)
        }
        
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertView.showAnimate()
    }
}

