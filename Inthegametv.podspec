Pod::Spec.new do |s|
    s.name         = "Inthegametv"
    s.version      = "2.3.0"
    s.summary      = "Inthegametv SDK for iOS and tvOS"
    s.description  = "Inthegametv SDK for iOS and tvOS"
    s.homepage     = "www.inthegame.io"
    s.license = { :type => "Commercial", :text => "See www.inthegame.io" }
    s.author       = { "Inthegame" => "itai@inthegame.io" }
    s.source       = { :git => "https://github.com/Inthegamesdk/itg-apple-sdk.git", :tag => "2.3.0" }
    s.platform = :ios, :tvos
    s.ios.deployment_target  = '14.3'
    s.tvos.deployment_target  = '14.0'
    s.requires_arc = true
    s.ios.vendored_frameworks = "**/**/InthegametviOS.xcframework", "**/**/Storket.xcframework"
    s.tvos.vendored_frameworks = "**/**/Inthegametv.xcframework", "**/**/Storket.xcframework"
    s.pod_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.user_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
end
