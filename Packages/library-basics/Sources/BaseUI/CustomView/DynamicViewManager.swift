//
//  DynamicViewManager.swift
//  ModuleMessage
//
//  Created by Janlor on 2024/7/25.
//

import UIKit

public class DynamicViewManager<ModelType, ViewType: UIView> {
    private let containerStackView: UIStackView
    private let createView: () -> ViewType
    private let setupView: (ViewType, ModelType) -> Void
    private let fixedViewCount: Int
    private let extraSetup: ((ViewType, Int) -> Void)?
    
    public init(container: UIStackView,
                createView: @escaping () -> ViewType,
                setupView: @escaping (ViewType, ModelType) -> Void,
                fixedCount: Int = 0,
                extraSetup: ((ViewType, Int) -> Void)? = nil) {
        self.containerStackView = container
        self.createView = createView
        self.setupView = setupView
        self.fixedViewCount = fixedCount
        self.extraSetup = extraSetup
    }
    
    public func setupModels(_ models: [ModelType]?) {
        guard let models = models, !models.isEmpty else {
            for view in containerStackView.arrangedSubviews.dropFirst(fixedViewCount) {
                view.isHidden = true
            }
            return
        }
        
        let oldViewCount = containerStackView.arrangedSubviews.count - fixedViewCount
        let maxCount = max(models.count, oldViewCount)
        for index in 0 ..< maxCount {
            let viewIndex = index + fixedViewCount
            guard index < models.count else {
                if viewIndex < containerStackView.arrangedSubviews.count {
                    containerStackView.arrangedSubviews[viewIndex].isHidden = true
                }
                continue
            }
            let model = models[index]
            guard index < oldViewCount else {
                let view = createView()
                view.isHidden = false
                setupView(view, model)
                containerStackView.addArrangedSubview(view)
                extraSetup?(view, index)
                continue
            }
            if viewIndex < containerStackView.arrangedSubviews.count,
               let view = containerStackView.arrangedSubviews[viewIndex] as? ViewType {
                view.isHidden = false
                setupView(view, model)
                extraSetup?(view, index)
            }
        }
    }
}

// Usage Example

//class TitleValueView: UIView {
//    let titleLabel = UILabel()
//    let valueLabel = UILabel()
//    // Add other view setup code here
//}
//
//struct TitleValueModel {
//    let title: String
//    let value: String
//}
//
//func createTitleValueView() -> TitleValueView {
//    let view = TitleValueView()
//    view.layoutMargins = UIEdgeInsets.zero
//    return view
//}
//
//func setupTitleValueView(_ view: TitleValueView, model: TitleValueModel) {
//    view.titleLabel.text = model.title
//    view.valueLabel.text = formattedScaleNumber(model.value)
//}
//
//let containerStackView = UIStackView()
//let viewManager = DynamicViewManager(
//    containerStackView: containerStackView,
//    createView: createTitleValueView,
//    setupView: setupTitleValueView,
//    fixedViewCount: 2 // Assuming first two views are fixed (e.g., title and separator)
//)
//
//// Now you can use viewManager to setup models
//let models = [TitleValueModel(title: "Title1", value: "Value1"), TitleValueModel(title: "Title2", value: "Value2")]
//viewManager.setupModels(models)

