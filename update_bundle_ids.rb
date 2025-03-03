#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Xcode project
project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

# Update settings for each target
project.targets.each do |target|
  target_name = target.name
  
  # Set appropriate bundle ID based on target name
  if target_name == "FOMO_PR"
    bundle_id = "com.fomoapp.fomopr"
  elsif target_name == "Core"
    bundle_id = "com.fomoapp.fomopr.Core"
  elsif target_name == "Models"
    bundle_id = "com.fomoapp.fomopr.Models"
  else
    next
  end
  
  # Update build settings for all configurations
  target.build_configurations.each do |config|
    # Enable code signing
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = bundle_id
    
    # Remove any settings that prevent code signing
    config.build_settings.delete('CODE_SIGNING_ALLOWED[sdk=iphonesimulator*]')
    config.build_settings.delete('CODE_SIGNING_REQUIRED[sdk=iphonesimulator*]')
  end
end

# Save the project
project.save
