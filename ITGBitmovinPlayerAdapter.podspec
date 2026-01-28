Pod::Spec.new do |s|
    s.name         = "ITGBitmovinPlayerAdapter"
    s.version      = "2.7.9"
    s.summary      = "Inthegametv adapter for Bitmovin player"
    s.description  = "Inthegametv adapter for Bitmovin player"
    s.homepage     = "www.inthegame.io"
    s.license = { :type => "Commercial", :text => "See www.inthegame.io" }
    s.author       = { "Inthegame" => "itai@inthegame.io" }
    s.source       = { :git => "https://github.com/Inthegamesdk/itg-apple-sdk.git", :tag => s.version.to_s }
    s.platform = :ios, :tvos
    s.ios.deployment_target  = '15.0'
    s.tvos.deployment_target  = '15.0'
    s.dependency 'Inthegametv', '~> 2.7.9'
    s.dependency 'BitmovinPlayer'
    s.source_files = '**/**/ITGBitmovinPlayerAdapter.swift', '**/**/ITGPlayerAdapter.swift', '**/**/ITGPlayerViewController.swift'
    s.pod_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.user_target_xcconfig = {
        'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO'
    }
    s.swift_version = '5.0'
end
