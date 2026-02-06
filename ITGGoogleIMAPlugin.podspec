Pod::Spec.new do |s|
    s.name         = "ITGGoogleIMAPlugin"
    s.version      = "2.7.11"
    s.summary      = "ITGGoogleIMAPlugin component for integration with Inthegametv SDK"
    s.description  = "ITGGoogleIMAPlugin component for integration with Inthegametv SDK"
    s.homepage     = "www.inthegame.io"
    s.license = { :type => "Commercial", :text => "See www.inthegame.io" }
    s.author       = { "Inthegame" => "itai@inthegame.io" }
    s.source       = { :git => "https://github.com/Inthegamesdk/itg-apple-sdk.git", :tag => s.version.to_s }
    s.platform = :ios, :tvos
    s.ios.deployment_target  = '15.0'
    s.tvos.deployment_target  = '15.0'
    s.dependency 'Inthegametv', '~> 2.7.11'
    s.source_files = '**/**/ITGGoogleIMAPlugin.swift'
    s.pod_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.user_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.swift_version = '5.0'
end
