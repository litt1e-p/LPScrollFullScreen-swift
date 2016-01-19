Pod::Spec.new do |s|
  s.name             = "LPScrollFullScreen-swift"
  s.version          = "1.0.0"
  s.summary          = "swift version for scroll to fullScreen."
  s.description      = <<-DESC
                       swift rewrite version for scroll to fullScreen.
                       DESC
  s.homepage         = "https://github.com/litt1e-p/LPScrollFullScreen-swift"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = { :type => 'MIT' }
  s.author           = { "litt1e-p" => "litt1e.p4ul@gmail.com" }
  s.source           = { :git => "https://github.com/litt1e-p/LPScrollFullScreen-swift.git", :tag => '1.0.0' }
  # s.social_media_url = 'https://twitter.com/NAME'
  s.platform = :ios, '8.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true
  s.source_files = 'LPScrollFullScreen-swift/*'\
  # s.resources = 'Assets'
  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'
end
