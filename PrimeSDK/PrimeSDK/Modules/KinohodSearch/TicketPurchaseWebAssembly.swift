import Foundation

class TicketPurchaseWebAssembly {
    var schedule: KinohodTicketsBookerScheduleViewModel.Schedule
    var sdkManager: PrimeSDKManagerProtocol

    init(
        schedule: KinohodTicketsBookerScheduleViewModel.Schedule,
        sdkManager: PrimeSDKManagerProtocol
    ) {
        self.schedule = schedule
        self.sdkManager = sdkManager
    }

    func make() -> UIViewController {
        let controller = TicketPurchaseWebViewController()
        controller.schedule = schedule
        controller.sdkManager = sdkManager
        return controller
    }
}
