#
#  Be sure to run `pod spec lint sequencing-file-selector-api-objc.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "sequencing-file-selector-api-objc"
  s.version      = "1.0.2"
  s.summary      = "File Selector CocoaPod plugin for adding Squencing.com's Real-Time Personalization technology to iOS apps coded in Objective-C"
  s.homepage     = "https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Sequencing" => "gittaca@sequencing.com" }
  s.source       = { 
  :git => "https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC.git", 
  :tag => "1.0.2" 
  }
  s.platform     = :ios, '9.0'
  s.source_files = 'Pod', 'Pod/**/*.*'  
#  s.resource = 'Pod/ResourceBundle.bundle'
#  s.resources = ['Pod/ResourceBundle.bundle/*.png']
  s.resources = ['Resources/**/*.*']
#  s.resource_bundles = {'TestResourceBundle' => ['Pod/ResourceBundle.bundle/*.png']}
  s.requires_arc = true
  

end
