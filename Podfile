# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

workspace 'AppBuilderSDK.xcworkspace'
project 'AppBuilderSDK.xcodeproj'
project 'PrimeSDK/PrimeSDK.xcodeproj'

def shared_pods
    pod 'Alamofire', '4.7.3'
    pod 'SwiftyJSON', '5.0.0'
    pod 'PromiseKit', '6.5.2'
    pod 'UIColor_Hex_Swift', '~> 4.2.0'
    pod 'Nuke', '8.3.1'
    pod 'STRegex', '2.0.0'
    pod 'SnapKit', '5.0.0'
    pod 'GoogleMaps', '2.7.0'
    pod 'SwiftLint', '0.33.0'
    pod 'YandexMobileAds/Dynamic', '2.20.0'
    pod 'SwiftMessages', '7.0.0'
    pod 'TagListView', '1.3.2'
    pod 'Branch', '0.37.0'
    pod 'UICollectionViewLeftAlignedLayout', :git => 'https://github.com/coeur/UICollectionViewLeftAlignedLayout.git'
    pod 'FloatingPanel', '1.7.1'
    pod 'SkeletonView', '1.8.2'
    pod 'DeckTransition', '2.1.0'
    pod 'YoutubeKit', '0.5.0'
    pod 'Nuke-WebP-Plugin', '4.0.0'
end

target 'PrimeSDK' do
    project 'PrimeSDK/PrimeSDK.xcodeproj'
    shared_pods
end

target 'PrimeSDKTests' do
    project 'PrimeSDK/PrimeSDK.xcodeproj'
    shared_pods
    pod 'Nimble', '8.0.2'
    pod 'Quick', '2.1.0'
end

target 'AppBuilderSDK' do
    project 'AppBuilderSDK.xcodeproj'
    shared_pods
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
         config.build_settings['SWIFT_VERSION'] = '5'
         config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
         config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
     end
 end
end
