Pod::Spec.new do |s|
  s.name             = 'Rudder-Braze'
  s.version          = '0.1.0-beta.1'
  s.summary          = 'Privacy and Security focused Segment-alternative. Braze Native SDK integration support.'

  s.description      = <<-DESC
Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
                       DESC

  s.homepage         = 'https://github.com/rudderlabs/rudder-integration-braze-ios'
  s.license          = { :type => "Apache", :file => "LICENSE" }
  s.author           = { 'Rudderlabs' => 'raj@rudderlabs.com' }
  s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-braze-ios.git', :commit => 'a05749a0e1fd8de99afb6129a2a75fc328367ca7' }
  s.platform         = :ios, "9.0"



  s.source_files = 'Rudder-Braze/Classes/**/*'

  s.dependency 'Rudder', '1.0.1-beta.4'
  s.dependency 'Appboy-iOS-SDK', '~>3.21.0'
end
