Pod::Spec.new do |s|
    s.name         = "ITGBitmovinPlayerAdapter"
    s.version      = "2.7.31"
    s.summary      = "Inthegametv adapter for Bitmovin player"
    s.description  = "Inthegametv adapter for Bitmovin player"
    s.homepage     = "www.inthegame.io"
    s.license = { :type => "Commercial", :text => "See www.inthegame.io" }
    s.author       = { "Inthegame" => "itai@inthegame.io" }
    s.source       = { :git => "https://github.com/Inthegamesdk/itg-apple-sdk.git", :tag => s.version.to_s }
    s.platform = :ios, :tvos
    s.ios.deployment_target  = '14.0'
    s.tvos.deployment_target  = '14.0'
    s.dependency 'ITGPlayerViewController', '~> 2.7.31'
    s.dependency 'BitmovinPlayer'
    s.vendored_frameworks = 'Sources/Plugins/ItgBitmovinPlayerAdapter.xcframework'
    s.pod_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.user_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.swift_version = '5.0'
end
