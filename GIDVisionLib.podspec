Pod::Spec.new do |s|
  s.name         = "GIDVisionLib"
  s.version      = "1.1.8"
  s.summary      = "OCR Wrapup library "
  s.description  = "this library containing OCR capabilities using frame by frame at video capabilities"

  s.homepage     = "https://github.com/noveriojoee/GIDVisionLib"
  s.license      = { :type => "MIT", :text => "The MIT License (MIT) \n Copyright (c) Noveriojoee <noverio.joe.hasibuan@outlook.co.id> \n Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files" }
  s.author             = { "noveriojoee" => "noverio.joe.hasibuan@outlook.co.id" }  
  s.source       = { :git => "https://github.com/noveriojoee/GIDVisionLib.git", 
                     :tag => "#{s.version}" }

  s.resources = "GIDVisionLib/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  s.source_files = "GIDVisionLib/**/*.{h,m}"
  s.ios.deployment_target = '9.0'
  s.static_framework = true

  # Specified all the dependencies here
  s.dependency 'GoogleMobileVision/TextDetector'
  s.exclude_files = "Classes/Exclude"


end