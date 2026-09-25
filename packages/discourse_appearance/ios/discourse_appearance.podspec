Pod::Spec.new do |s|
  s.name             = 'discourse_appearance'
  s.version          = '0.1.0'
  s.summary          = "Carries the app's light/dark choice to the native layer."
  s.description      = "Forces the platform appearance to the in-app light/dark choice so web views and system UI match."
  s.homepage         = 'https://github.com/forumcopilot/discourse-app'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'ForumCopilot'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
