Pod::Spec.new do |s|
  s.name         = "AnimatingLabel"
  s.version      = "1.0"
  s.summary      = "Adds animation feature for numeric values in UILabel."
  s.homepage     = "https://github.com/codewise/AnimatingLabel"
  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  s.author       = { "Paweł Sękara" => "pawel.sekara@gmail.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/codewise/AnimatingLabel.git", :tag => "1.0" }

  s.source_files  = "AnimatingLabel"
  s.requires_arc = true
end