Pod::Spec.new do |s|
    s.name         = "ITGMediastreamPlatformAdapter"
    s.version      = "2.6.48"
    s.summary      = "Inthegametv adapter for MediastreamPlatform"
    s.description  = "Inthegametv adapter for MediastreamPlatform"
    s.homepage     = "www.inthegame.io"
    s.license = { :type => "Commercial", :text => "See www.inthegame.io" }
    s.author       = { "Inthegame" => "itai@inthegame.io" }
    s.source       = { :git => "https://github.com/Inthegamesdk/itg-apple-sdk.git", :tag => s.version.to_s }
    s.platform = :ios, :tvos
    s.ios.deployment_target  = '12.0'
    s.tvos.deployment_target  = '12.0'
    s.dependency 'Inthegametv', '~> 2.6.48'
    s.source_files = '**/**/**/ITGMediastreamPlatformAdapter.swift', '**/**/**/ITGPlayerAdapter.swift', '**/**/**/ITGPlayerViewController.swift'
    s.pod_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.user_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.swift_version = '5.0'
end
