
import UIKit
import SVProgressHUD

public enum ProgressHUDMaskType: UInt {
    case none = 1       // default mask type, allow user interactions while HUD is displayed
    case clear          // don't allow user interactions with background objects
    case black          // don't allow user interactions with background objects and dim the UI in the back of the HUD (as seen in iOS 7 and above)
    case gradient       // don't allow user interactions with background objects and dim the UI with a a-la UIAlertView background gradient (as seen in iOS 6)
    case custom         // don't allow user interactions with background objects and dim the UI in the back of the HUD with a custom color
}


public class ProgressHUD {
    
    static let defaultMaskType: ProgressHUDMaskType = .none
    static let customInfoMinimumSize = CGSize(width: 180, height: 62)
    static let customMinimumSize = CGSize(width: 100, height: 100)
    
    // MARK: - Public
    
    public static func setSVProgressHUD() {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setForegroundColor(UIColor.theme.label)
        SVProgressHUD.setBackgroundColor(UIColor.theme.secondaryBackground)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setFont(UIFont.theme.body)
    }
    
    public static func show() {
        show(withStatus: nil, maskType: defaultMaskType)
    }
    
    public static func show(withStatus status: String?) {
        show(withStatus: status, maskType: defaultMaskType)
    }
    
    public static func show(maskType: ProgressHUDMaskType) {
        show(withStatus: nil, maskType: maskType)
    }
    
    public static func show(withStatus status: String?, maskType: ProgressHUDMaskType) {
        resetDefaultAppearance()
        
        let mask = SVProgressHUDMaskType(rawValue: maskType.rawValue) ?? SVProgressHUDMaskType.none
        SVProgressHUD.setDefaultMaskType(mask)
        SVProgressHUD.setCornerRadius(8.0)
        SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 12))
        SVProgressHUD.setImageViewSize(CGSize(width: 100, height: 12))
        SVProgressHUD.setMinimumDismissTimeInterval(CGFloat.greatestFiniteMagnitude)
        SVProgressHUD.show(withStatus: status)
    }
    
    public static func show(in view: UIView, status: String?) {
        show(in: view, status: status, offsetFromCenter: UIOffset(horizontal: 0, vertical: 0))
    }
    
    public static func show(in view: UIView, status: String?, offsetFromCenter offset: UIOffset) {
        resetDefaultAppearance()
        SVProgressHUD.setContainerView(view)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
        SVProgressHUD.setCornerRadius(8.0)
        SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 12))
        SVProgressHUD.setImageViewSize(CGSize(width: 100, height: 12))
        SVProgressHUD.setOffsetFromCenter(offset)
        SVProgressHUD.setMinimumDismissTimeInterval(CGFloat.greatestFiniteMagnitude)
        SVProgressHUD.show(withStatus: status)
    }
    
    public static func showProgress(_ progress: Float) {
        showProgress(progress, status: nil)
    }
    
    public static func showProgress(_ progress: Float, status: String?) {
        showProgress(progress, status: status, maskType: defaultMaskType)
    }
    
    public static func showProgress(_ progress: Float, status: String?, maskType: ProgressHUDMaskType) {
        resetDefaultAppearance()
        let mask = SVProgressHUDMaskType(rawValue: maskType.rawValue) ?? SVProgressHUDMaskType.none
        SVProgressHUD.setDefaultMaskType(mask)
        if let _ = status {
            SVProgressHUD.setMinimumSize(customMinimumSize)
        }
        SVProgressHUD.showProgress(progress, status: status)
    }
    
    public static func showInfo(withStatus status: String?) {
        guard let status = status, !status.isEmpty else { return }
        resetDefaultAppearance()
//        SVProgressHUD.setInfoImage(UIImage())
        SVProgressHUD.setCornerRadius(8)
        SVProgressHUD.setMinimumSize(customInfoMinimumSize)
        SVProgressHUD.showInfo(withStatus: status)
    }
    
    public static func showInfo(withStatus status: String?, maskType: ProgressHUDMaskType) {
        guard let status = status, !status.isEmpty else { return }
        resetDefaultAppearance()
//        SVProgressHUD.setInfoImage(UIImage())
        SVProgressHUD.setCornerRadius(8)
        SVProgressHUD.setMinimumSize(customInfoMinimumSize)
        let mask = SVProgressHUDMaskType(rawValue: maskType.rawValue) ?? SVProgressHUDMaskType.none
        SVProgressHUD.setDefaultMaskType(mask)
        SVProgressHUD.showInfo(withStatus: status)
    }
    
    public static func showSuccess(withStatus status: String?) {
        resetDefaultAppearance()
        if let _ = status {
            SVProgressHUD.setMinimumSize(customMinimumSize)
        }
        SVProgressHUD.showSuccess(withStatus: status)
    }
    
    public static func showError(withStatus status: String?) {
        guard let status = status, !status.isEmpty else { return }
        resetDefaultAppearance()
        SVProgressHUD.setMinimumSize(customMinimumSize)
        SVProgressHUD.showError(withStatus: status)
    }
    
    public static func isVisible() -> Bool {
        SVProgressHUD.isVisible()
    }
    
    public static func dismiss() {
        SVProgressHUD.dismiss()
    }
    
    // MARK: - Private
    
    public static func resetDefaultAppearance() {
        SVProgressHUD.setCornerRadius(14.0)
        SVProgressHUD.setContainerView(nil)
        SVProgressHUD.setMinimumSize(.zero)
        let mask = SVProgressHUDMaskType(rawValue: defaultMaskType.rawValue) ?? SVProgressHUDMaskType.none
        SVProgressHUD.setDefaultMaskType(mask)
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setImageViewSize(CGSize(width: 28, height: 28))
        SVProgressHUD.setForegroundColor(UIColor.theme.label)
        SVProgressHUD.setBackgroundColor(UIColor.theme.secondaryBackground)
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        SVProgressHUD.resetOffsetFromCenter()
    }
}
