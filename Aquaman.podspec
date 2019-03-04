Pod::Spec.new do |s|
  s.name             = "Aquaman"
  s.version          = "0.0.2"
  s.summary          = "基于AFNetworking的网络库封装"
  s.homepage         = "https://github.com/bawn/Aquaman"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.authors          = { "bawn" => "lc5491137@gmail.com" }
  s.swift_version    = "4.2"
  s.source           = { :git => "https://github.com/bawn/Aquaman.git", :tag => s.version.to_s }
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.source_files     = 'Aquaman/Aquaman/*.swift'
end
