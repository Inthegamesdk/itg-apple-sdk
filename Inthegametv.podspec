Pod::Spec.new do |s|
    s.name         = "Inthegametv"
    s.version      = "2.6.0"
    s.summary      = "Inthegametv SDK for tvOS"
    s.description  = "Inthegametv SDK for tvOS"
    s.homepage     = "www.inthegame.io"
    s.license = { :type => "Commercial", :text => "See www.inthegame.io" }
    s.author       = { "Inthegame" => "itai@inthegame.io" }
    s.source       = { :git => "https://github.com/Inthegamesdk/itg-apple-sdk.git", :tag => "2.6.0" }
    s.platform = :tvos
    s.tvos.deployment_target  = '14.0'
    s.requires_arc = true
    s.tvos.vendored_frameworks = "**/**/Inthegametv.xcframework", "**/**/Storket.xcframework"
    s.pod_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.user_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
end
