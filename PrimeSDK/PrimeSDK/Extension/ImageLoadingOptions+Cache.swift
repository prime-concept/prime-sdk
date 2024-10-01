import Foundation
import Nuke

extension ImageLoadingOptions {
    static var cacheOptions: ImageLoadingOptions {
        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline {
            $0.dataLoader = DataLoader(
                configuration: {
                    let conf = DataLoader.defaultConfiguration
                    conf.urlCache = nil
                    return conf
                }()
            )

            $0.imageCache = ImageCache()
            $0.dataCache = try? DataCache(name: "ru.com.technolab.primesdk.ImageCache")
        }
        return options
    }
}
