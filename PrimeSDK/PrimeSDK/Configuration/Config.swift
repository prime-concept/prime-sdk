import Foundation

enum Config {
    static func uploadCertificates() -> [Data] {
        let certificates: [Data] = Bundle.main
            .urls(
                forResourcesWithExtension: "der",
                subdirectory: nil
            )?.compactMap {
                do {
                    return try Data(contentsOf: $0)
                } catch let error {
                    assertionFailure("Не получается загрузить сертификат: \(error)")
                    return nil
                }
            } ?? []

        assert(!certificates.isEmpty, "Сертификаты не найдены")
        return certificates
    }
}

