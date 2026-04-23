//
//  Date+Extension.swift
//  LibraryBasics
//
//  Created by Janlor on 4/22/26.
//

import Foundation

public extension Date {
    
    // MARK: - Compare
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var isThisWeek: Bool {
        isEqual(granularity: .weekOfYear)
    }
    
    var isThisMonth: Bool {
        isEqual(granularity: .month)
    }
    
    var isThisYear: Bool {
        isEqual(granularity: .year)
    }
    
    func isSameDay(_ date: Date) -> Bool {
        isEqual(date, granularity: .day)
    }
    
    func isEqual(_ date: Date = Date(), granularity: Calendar.Component) -> Bool {
        Calendar.current.isDate(self, equalTo: date, toGranularity: granularity)
    }
    
    func isEqual(_ date: Date = Date(), componentSet: Set<Calendar.Component>) -> Bool {
        let selfComponents = Calendar.current.dateComponents(componentSet, from: self)
        let otherComponents = Calendar.current.dateComponents(componentSet, from: date)
        for component in componentSet {
            guard let lhs = selfComponents.value(for: component),
                  let rhs = otherComponents.value(for: component) else {
                return false
            }
            if lhs == rhs {
                continue
            } else {
                return false
            }
        }
        return true
    }
    
    /// 判断是不是比指定日期早
    /// - Parameter aDate: 指定的日期
    /// - Returns: true 早 false 不早
    func isEarlier(than aDate: Date?) -> Bool {
        guard let aDate = aDate else { return false }
        return self.compare(aDate) == .orderedAscending
    }
    
    /// 判断是不是比指定日期晚
    /// - Parameter aDate: 指定的日期
    /// - Returns: true 晚 false 不晚
    func isLater(than aDate: Date?) -> Bool {
        guard let aDate = aDate else { return false }
        return self.compare(aDate) == .orderedDescending
    }
    
    // MARK: - Property getter
    
    static let secondsInOneMinute: TimeInterval  = 60
    static let secondsInOneHour: TimeInterval  = 60 * 60
    static let secondsInOneDay: TimeInterval  = 60 * 60 * 24
    static let secondsInOneWeek: TimeInterval  = 60 * 60 * 24 * 7
    
    static let allComponentSet: Set<Calendar.Component> = [.era, .year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear, .nanosecond, .calendar, .timeZone]
    
    var allComponents: DateComponents {
        Calendar.current.dateComponents(Date.allComponentSet, from: self)
    }
    
    @available(iOS 8.0, macOS 10.9, *)
    func component(_ unit: Calendar.Component) -> Int {
        Calendar.current.component(unit, from: self)
    }
    
    var era: Int {
        component(.era) // allComponents.era
    }
    
    var year: Int {
        component(.year)
    }
    
    var month: Int {
        component(.month)
    }
    
    var day: Int {
        component(.day)
    }
    
    var hour: Int {
        component(.hour)
    }
    
    var minute: Int {
        component(.minute)
    }
    
    var second: Int {
        component(.second)
    }
    
    var weekday: Int {
        component(.weekday)
    }
    
    var weekdayOrdinal: Int {
        component(.weekdayOrdinal)
    }
    
    var quarter: Int {
        component(.quarter)
    }
    
    var weekOfMonth: Int {
        component(.weekOfMonth)
    }
    
    var weekOfYear: Int {
        component(.weekOfYear)
    }
    
    var yearForWeekOfYear: Int {
        component(.yearForWeekOfYear)
    }
    
    var nanosecond: Int {
        component(.nanosecond)
    }
    
    var calendar: Int {
        component(.calendar)
    }
    
    var timeZone: Int {
        component(.timeZone)
    }
    
    var isLeapMonth: Bool {
        allComponents.isLeapMonth ?? false
    }
    
    var isLeapYear: Bool {
        (year % 100 == 0) ? (year % 400 == 0) : (year % 4 == 0)
    }
    
    // MARK: - Calculate.
    
    // MARK: All calculations depend on time interval , not `Calendar`.
    
    func addingMinutes(_ count: Int) -> Date {
        self + TimeInterval(Date.secondsInOneMinute * Double(count))
    }
    
    func subtractingMinutes(_ count: Int) -> Date {
        addingMinutes(-count)
    }
    
    func addingDays(_ count: Int) -> Date {
        // equals to  `self.addingTimeInterval(TimeInterval(Date.secondsInOneDay * Double(count)))`
        self + TimeInterval(Date.secondsInOneDay * Double(count))
    }
    
    func subtractingDays(_ count: Int) -> Date {
        addingDays(-count)
    }
    
    func addingWeeks(_ count: Int) -> Date {
        self + TimeInterval(Date.secondsInOneWeek * Double(count))
    }
    
    func subtractingWeeks(_ count: Int) -> Date {
        addingWeeks(-count)
    }
    
    // MARK: All calculations depend on `Calendar`, not time interval.
    
    func addingMonths(_ count: Int) -> Date? {
        Calendar.current.date(byAdding: .month, value: count, to: self)
    }
    
    func subtractingMonths(_ count: Int) -> Date? {
        addingMonths(-count)
    }
    
    func addingYears(_ count: Int) -> Date? {
        Calendar.current.date(byAdding: .year, value: count, to: self)
    }
    
    func subtractingYears(_ count: Int) -> Date? {
        addingYears(-count)
    }
    
    // MARK: Other calculations.
    
    var isThisWeekInChina: Bool {
        self.isSameWeekInChina(Date())
    }
    
    func isSameWeekInChina(_ date: Date) -> Bool {
        subtractingDays(weekdayIndexInChina).isSameDay(date.subtractingDays(date.weekdayIndexInChina))
    }
    
    var weekdayIndex: Int {
        (weekday + 6) % 7
    }
    
    var weekdayIndexInChina: Int {
        (weekday + 5) % 7
    }
    
    // MARK: - Interval
    
    func timeInterval(_ to: Date = Date()) -> TimeInterval {
        to.timeIntervalSince(self)
    }
    
    func interval(_ component: Calendar.Component,
                  _ to: Date = Date()) -> Int? {
        let dateComponet = Calendar.current.dateComponents([component], from: self, to: to)
        return dateComponet.value(for: component)
    }
    
    func secondsInterval(_ date: Date) -> Double {
        timeInterval()
    }
    
    func minutesInterval(_ date: Date) -> Double {
        timeInterval() / Double(Date.secondsInOneMinute)
    }
    
    func hoursInterval(_ date: Date) -> Double {
        timeInterval() / Double(Date.secondsInOneHour)
    }
    
    func daysInterval(_ date: Date) -> Double {
        timeInterval() / Double(Date.secondsInOneDay)
    }
    
    func weeksInterval(_ date: Date) -> Double {
        timeInterval() / Double(Date.secondsInOneWeek)
    }
    
    func monthsInterval(_ date: Date) -> Int? {
        interval(.month)
    }
    
    func yearsInterval(_ date: Date) -> Int? {
        interval(.year)
    }
    
    // MARK: - Format string / create a date with format
    
    func string(_ format: String,
                timeZone: TimeZone = TimeZone.current,
                locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return string(dateFormatter, timeZone: timeZone, locale: locale)
    }
    
    func string(_ dateFormatter: DateFormatter,
                timeZone: TimeZone = TimeZone.current,
                locale: Locale = Locale.current) -> String {
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale
        return dateFormatter.string(from: self)
    }
    
    static let ISODateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    var ISOString: String {
        Date.ISODateFormatter.string(from: self)
    }
    
    static func date(_ date: String,
                     format: String,
                     timeZone: TimeZone = TimeZone.current,
                     locale: Locale = Locale.current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale
        return dateFormatter.date(from: date)
    }
    
    static func date(_ ISOString: String) -> Date? {
        Date.ISODateFormatter.date(from: ISOString)
    }
    
}
