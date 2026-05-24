# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'GoRider' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GoRider
    pod 'AlamofireImage', '~> 4.0'
    pod 'IQKeyboardManagerSwift', '~> 7.0'
    pod 'SkyFloatingLabelTextField', '~> 4.0'
    pod 'Cosmos', '~> 25.0'
    # RangeSeekSlider - rimosso, incompatibile con iOS 26, sostituito con RangeSliderView.swift custom
    pod 'MOLH', '~> 1.4'
    
    pod 'GooglePlaces', '~> 8.5'
    
    #Social Login
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'GoogleSignIn', '~> 7.0'
    
    pod 'NotificationBannerSwift', '~> 3.2'
    pod 'Stripe', '~> 25.7'
    pod 'StripePaymentSheet', '~> 25.7'
    # lottie-ios rimosso — splash animation ora usa SwiftUI nativo (SplashAnimationView)

end

post_install do |installer|
  # Sopprimere tutti i warning nei Pods
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "14.0"
      config.build_settings["GCC_WARN_INHIBIT_ALL_WARNINGS"] = "YES"
      config.build_settings["CLANG_WARN_DOCUMENTATION_COMMENTS"] = "NO"
      config.build_settings["SWIFT_SUPPRESS_WARNINGS"] = "YES"
    end
  end
  
  # Applica anche al main target
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.user_project.native_targets.each do |native_target|
      native_target.build_configurations.each do |config|
        config.build_settings["SWIFT_SUPPRESS_WARNINGS"] = "YES"
      end
    end
    aggregate_target.user_project.save
  end
end
