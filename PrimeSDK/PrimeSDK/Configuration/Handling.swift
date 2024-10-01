import Foundation

struct Handling<I, O> {
    var handle: (I) -> O

    init(handler: @escaping (I) -> O) {
        handle = handler
    }

    static func handle(_ handler: @escaping (I) -> O) -> Handling<I, O> { .init(handler: handler) }
}


extension Handling {
    /// Связывание хендлеров в цепочку.
    ///
    /// Управление передается следующему хендлеру до тех пор пока условие
    /// `passOverWhen` не вернет `false`. Если после прохождения по всем хендлерам
    /// условие `passOver` не сработает, то вернется результат исполнения первого хендлера.
    static func chain(
        first: Handling,
        other handlers: [Handling],
        passOverWhen passOver: @escaping (O) -> Bool
    ) -> Handling {
        .handle {
            let firstHandlerResult = first.handle($0)
            guard passOver(firstHandlerResult) else {
                return firstHandlerResult
            }

            for handler in handlers {
                let handlingResult = handler.handle($0)
                guard passOver(handlingResult) else {
                    return handlingResult
                }
            }

            return firstHandlerResult
        }
    }
}
