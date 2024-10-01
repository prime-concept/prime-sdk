import Foundation

extension Date {
    init?(string: String) {
        let firstDateFormatter = DateFormatter()
        firstDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        firstDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        firstDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let secondDateFormatter = DateFormatter()
        secondDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        secondDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let thirdDateFormatter = DateFormatter()
        thirdDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
        thirdDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let fourthDateFormatter = DateFormatter()
        fourthDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        fourthDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let fifthDateFormatter = DateFormatter()
        fifthDateFormatter.dateFormat = "yyyy-MM-dd"
        fifthDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let dateFormatters = [
            firstDateFormatter,
            secondDateFormatter,
            thirdDateFormatter,
            fourthDateFormatter,
            fifthDateFormatter
        ]

        for dateFormatter in dateFormatters {
            if let date = dateFormatter.date(from: string) {
                self = date
                return
            }
        }
        return nil
    }
}
