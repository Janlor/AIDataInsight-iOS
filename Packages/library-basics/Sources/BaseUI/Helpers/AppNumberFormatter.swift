//
//  AppNumberFormatter.swift
//  ModuleMessage
//
//  Created by Janlor on 4/22/26.
//

import Foundation

// MARK: - None

/// 纯数字 没有任何格式
public let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    return formatter
}()

// MARK: - Percent

/// 百分比格式化 保留两位小数
public let percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
    formatter.multiplier = 1
    formatter.percentSymbol = "%"
    return formatter
}()

/// 百分比格式化字符串 带百分号%
public func formattedPercentString(_ number: Double?, formatter: NumberFormatter? = percentFormatter) -> String? {
    guard let number = number else { return nil }
    let numStr = formatter?.string(from: NSNumber(value: number))
    return numStr
}

// MARK: - Decimal

/// 金额格式化
public let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}()

/// 格式化字符串 带数量级
public func formattedScaleNumber(_ number: Double?, formatter: NumberFormatter? = decimalFormatter) -> (String, String) {
    guard let number = number, number >= 0 else { return ("0", "") }

    let formattedNumber: String
    let suffix: String

    // 获取当前语言环境
    let locale = Locale.current.languageCode

    switch number {
    case 100_000_000...:
        if locale == "zh" {
            formattedNumber = formatter?.string(from: NSNumber(value: number / 100_000_000)) ?? "0"
            suffix = NSLocalizedString("亿", bundle: .module, comment: "")
        } else {
            formattedNumber = formatter?.string(from: NSNumber(value: number / 1_000_000_000)) ?? "0"
            suffix = "B"
        }
    case 10_000...:
        if locale == "zh" {
            formattedNumber = formatter?.string(from: NSNumber(value: number / 10_000)) ?? "0"
            suffix = NSLocalizedString("万", bundle: .module, comment: "")
        } else {
            formattedNumber = formatter?.string(from: NSNumber(value: number / 1_000)) ?? "0"
            suffix = "K"
        }
    default:
        formattedNumber = formatter?.string(from: NSNumber(value: number)) ?? "0"
        suffix = ""
    }

    return (formattedNumber, suffix)
}

/// 格式化字符串 带单位 吨
public func formattedScaleTon(_ num: Double?) -> String {
    let formatted = formattedScaleNumber(num)
    let locale = Locale.current.languageCode

    if locale == "zh" {
        return formatted.0 + formatted.1 + NSLocalizedString("吨", bundle: .module, comment: "")
    } else {
        return formatted.0 + formatted.1 + " MT"
    }
}

/// 格式化字符串 带单位 元
public func formattedScaleYuan(_ num: Double?) -> String {
    let formatted = formattedScaleNumber(num)
    let locale = Locale.current.languageCode

    if locale == "zh" {
        return formatted.0 + formatted.1 + NSLocalizedString("元", bundle: .module, comment: "")
    } else {
        return formatted.0 + formatted.1 + " CNY"
    }
}

/// 格式化字符串 带单位 天
public func formattedScaleDays(_ num: Double?) -> String {
    let formatted = formattedScaleNumber(num)
    let locale = Locale.current.languageCode

    if locale == "zh" {
        return formatted.0 + formatted.1 + NSLocalizedString("天", bundle: .module, comment: "")
    } else {
        return formatted.0 + formatted.1 + " days"
    }
}

/// 格式化字符串 带单位 分钟
public func formattedScaleMinutes(_ num: Double?) -> String {
    let formatted = formattedScaleNumber(num)
    let locale = Locale.current.languageCode

    if locale == "zh" {
        return formatted.0 + formatted.1 + NSLocalizedString("分钟", bundle: .module, comment: "")
    } else {
        return formatted.0 + formatted.1 + " minutes"
    }
}

// MARK: - Localized

public func localizedUnitDays(_ num: Double?) -> String {
    let format = NSLocalizedString("%.2f天", bundle: .module, comment: "")
    return String.localizedStringWithFormat(format, num ?? 0)
}

public func localizedUnitDays(_ num: Int?) -> String {
    let format = NSLocalizedString("%d天", bundle: .module, comment: "")
    return String.localizedStringWithFormat(format, num ?? 0)
}

public func localizedUnitTimes(_ num: Int?) -> String {
    let format = NSLocalizedString("%d次", bundle: .module, comment: "")
    return String.localizedStringWithFormat(format, num ?? 0)
}

public func localizedUnitCopies(_ num: Int?) -> String {
    let format = NSLocalizedString("%d份", bundle: .module, comment: "")
    return String.localizedStringWithFormat(format, num ?? 0)
}

// MARK: -

/// 格式化字符串 不带数量级也不带单位
public func formattedNumberString(_ number: Double?, formatter: NumberFormatter? = decimalFormatter) -> String {
    let number = max(0, number ?? 0)
    let formattedNumber = formatter?.string(from: NSNumber(value: number)) ?? "0"
    return formattedNumber
}

/// 格式化字符串 带单位 元
public func formattedNumberYuan(_ num: Double?) -> String {
    let formatted = formattedNumberString(num)
    let locale = Locale.current.languageCode
    if locale == "zh" {
        return formatted + NSLocalizedString("元", bundle: .module, comment: "")
    } else {
        return formatted + " CNY"
    }
}

/// 格式化字符串 带单位 吨
public func formattedNumberTon(_ num: Double?) -> String {
    let formatted = formattedNumberString(num)
    let locale = Locale.current.languageCode
    if locale == "zh" {
        return formatted + NSLocalizedString("吨", bundle: .module, comment: "")
    } else {
        return formatted + " MT"
    }
}

/// 格式化字符串 带单位 分钟
public func formattedNumberMinutes(_ num: Double?, formatter: NumberFormatter? = nil) -> String {
    var formatter = formatter
    if formatter == nil {
        formatter = NumberFormatter()
        formatter?.numberStyle = .decimal
        formatter?.minimumFractionDigits = 0
        formatter?.maximumFractionDigits = 0
    }
    let formatted = formattedNumberString(num, formatter: formatter)
    let locale = Locale.current.languageCode
    if locale == "zh" {
        return formatted + NSLocalizedString("分钟", bundle: .module, comment: "")
    } else {
        return formatted + " minutes"
    }
}

// MARK: - TenThousands

/// 格式化为 万 字符串 带数量级
public func formattedScaleNumberInTenThousands(_ number: Double?, formatter: NumberFormatter? = decimalFormatter) -> (String, String) {
    let number = number ?? 0

    let formattedNumber: String
    let suffix: String

    // 获取当前语言环境
    let locale = Locale.current.languageCode

    if locale == "zh" {
        formattedNumber = formatter?.string(from: NSNumber(value: number / 10000)) ?? "0"
        suffix = NSLocalizedString("万", bundle: .module, comment: "")
    } else {
        formattedNumber = formatter?.string(from: NSNumber(value: number / 1000)) ?? "0"
        suffix = "K"
    }

    return (formattedNumber, suffix)
}

/// 格式化为 万 字符串 带单位：元
public func formattedYuanInTenThousands(_ num: Double?) -> String {
    let formatted = formattedScaleNumberInTenThousands(num)
    let locale = Locale.current.languageCode

    if locale == "zh" {
        return formatted.0 + formatted.1 + NSLocalizedString("元", bundle: .module, comment: "")
    } else {
        return formatted.0 + formatted.1 + " CNY"
    }
}

/// 格式化为 吨 字符串 带单位：吨
public func formattedTonInTenThousands(_ num: Double?) -> String {
    let formatted = formattedScaleNumberInTenThousands(num)
    let locale = Locale.current.languageCode

    if locale == "zh" {
        return formatted.0 + formatted.1 + NSLocalizedString("吨", bundle: .module, comment: "")
    } else {
        return formatted.0 + formatted.1 + " MT"
    }
}

/// 格式化为 万 字符串 不带数量级也不带单位
public func formattedNumberInTenThousands(_ number: Double?, formatter: NumberFormatter? = decimalFormatter) -> String? {
    let number = number ?? 0
    let formattedNumber = formatter?.string(from: NSNumber(value: number / 10000))
    return formattedNumber
}

// MARK: - hundred million

/// 格式化为 亿 字符串 带数量级
public func formattedScaleNumberInHundredMillion(_ number: Double?, formatter: NumberFormatter? = decimalFormatter) -> (String, String) {
    let number = number ?? 0

    let formattedNumber: String
    let suffix: String

    // 获取当前语言环境
    let locale = Locale.current.languageCode
    
    if locale == "zh" {
        formattedNumber = formatter?.string(from: NSNumber(value: number / 100000000)) ?? "0"
        suffix = NSLocalizedString("亿", bundle: .module, comment: "")
    } else {
        formattedNumber = formatter?.string(from: NSNumber(value: number / 1000000000)) ?? "0"
        suffix = "B"
    }

    return (formattedNumber, suffix)
}

/// 格式化为 亿 字符串 带单位：元
public func formattedYuanInHundredMillion(_ num: Double?) -> String {
    let formatted = formattedScaleNumberInHundredMillion(num)
    let locale = Locale.current.languageCode

    if locale == "zh" {
        return formatted.0 + formatted.1 + NSLocalizedString("元", bundle: .module, comment: "")
    } else {
        return formatted.0 + formatted.1 + " CNY"
    }
}

/// 格式化为 亿 字符串 不带数量级也不带单位
public func formattedNumberInHundredMillion(_ number: Double?, formatter: NumberFormatter? = decimalFormatter) -> String? {
    guard let number = number, number >= 0 else { return nil }
    let formattedNumber: String = formatter?.string(from: NSNumber(value: number / 100000000)) ?? "0"
    return formattedNumber
}
