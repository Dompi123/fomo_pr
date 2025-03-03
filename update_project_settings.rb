#!/usr/bin/env ruby
require 'xcodeproj'

project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

# Find the Core target
core_target = project.targets.find { |t| t.name == 'Core' }
if core_target
  core_target.build_configurations.each do |config|
    # Enable code signing for Core target
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    
    # Remove the "Don't Code Sign" setting
    config.build_settings.delete('CODE_SIGN_IDENTITY[sdk=iphoneos*]')
    
    # Set proper bundle ID
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.fomoapp.fomopr.Core'
  end
  puts "Updated Core target settings"
end

# Find the Models target
models_target = project.targets.find { |t| t.name == 'Models' }
if models_target
  models_target.build_configurations.each do |config|
    # Enable code signing for Models target
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    
    # Remove the "Don't Code Sign" setting
    config.build_settings.delete('CODE_SIGN_IDENTITY[sdk=iphoneos*]')
    
    # Set proper bundle ID
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.fomoapp.fomopr.Models'
  end
  puts "Updated Models target settings"
end

# Find the main app target
main_target = project.targets.find { |t| t.name == 'FOMO_PR' }
if main_target
  main_target.build_configurations.each do |config|
    # Ensure code signing is enabled
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'YES'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'YES'
    config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
    
    # Set proper bundle ID
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.fomoapp.fomopr'
  end
  puts "Updated FOMO_PR target settings"
end

# Save the project
project.save
puts "Project settings updated successfully"
