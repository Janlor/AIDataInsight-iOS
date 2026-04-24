//
//  IntDuration.swift
//  LibraryCommon
//
//  Created by Janlor on 2024/5/22.
//

import Foundation

extension Int {
    /// 将分钟数转为 天 小时 分钟
    /// - Parameter minute: 分钟数
    /// - Returns: 字符串
    func timeMinuteDurationString() -> String {
        guard self > 0 else {
            let minute = 0
            return String.localizedStringWithFormat(NSLocalizedString("%d分钟", bundle: .module, comment: ""), minute)
        }
        
        var day = 0
        var hour = 0
        var minute = self
        
        if minute >= 60 {
            hour = minute / 60
            minute = minute % 60
        }
        
        if hour >= 24 {
            day = hour / 24
            hour = hour % 24
        }
        
        if hour == 0 {
            return String.localizedStringWithFormat(NSLocalizedString("%d分钟", bundle: .module, comment: ""), minute)
        }
        
        if day == 0 {
            return String.localizedStringWithFormat(NSLocalizedString("%d小时%d分钟", bundle: .module, comment: ""), hour, minute)
        }
        
        return String.localizedStringWithFormat(NSLocalizedString("%d天%d小时%d分钟", bundle: .module, comment: ""), day, hour, minute)
    }
    
    /// 将分钟数切割成天时分
    /// - Returns: 天时分元组
    func timeMinuteDuration() -> (day: Int, hour: Int, minute: Int) {
        guard self > 0 else {
            return (0, 0, 0)
        }
        
        var day = 0
        var hour = 0
        var minute = self
        
        if minute >= 60 {
            hour = minute / 60
            minute = minute % 60
        }
        
        if hour >= 24 {
            day = hour / 24
            hour = hour % 24
        }
        
        return (day, hour, minute)
    }
    
    /// 将时间戳转为电子时钟显示的字符串
    /// - Returns: 字符串
    func timeSecondDurationString() -> String {
        guard self > 0 else {
            return "00:00"
        }
        
        var day = 0
        var hour = 0
        var minute = 0
        var second = self
        
        if second >= 60 {
            minute = second / 60
            second = second % 60
        }
        
        if minute >= 60 {
            hour = minute / 60
            minute = minute % 60
        }
        
        if hour >= 24 {
            day = hour / 24
            hour = hour % 24
        }
        
        if hour == 0 {
            return String(format: "%02d:%02d", minute, second)
        }
        
        if day == 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        
        return String(format: "%02d:%02d:%02d:%02d", day, hour, minute, second)
    }
}
