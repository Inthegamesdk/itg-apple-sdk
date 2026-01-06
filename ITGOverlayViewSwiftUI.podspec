Pod::Spec.new do |s|
    s.name         = "ITGOverlayViewSwiftUI"
    s.version      = "2.6.51"
    s.summary      = "ITGOverlayViewSwiftUI component for integration of Inthegametv SDK using SwiftUI"
    s.description  = "ITGOverlayViewSwiftUI component for integration of Inthegametv SDK using SwiftUI"
    s.homepage     = "www.inthegame.io"
    s.license = { :type => "Commercial", :text => "See www.inthegame.io" }
    s.author       = { "Inthegame" => "itai@inthegame.io" }
    s.source       = { :git => "https://github.com/Inthegamesdk/itg-apple-sdk.git", :tag => s.version.to_s }
    s.platform = :ios, :tvos
    s.ios.deployment_target  = '13.0'
    s.tvos.deployment_target  = '13.0'
    s.dependency 'Inthegametv', '~> 2.6.51'
    s.source_files = '**/**/ITGOverlayViewSwiftUI.swift'
    s.pod_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.user_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.swift_version = '5.0'
end
