Pod::Spec.new do |s|

s.swift_versions = "5.0"

s.name         = "QXBookReader"
s.version      = "0.0.1"
s.summary      = "A book reader support .txt .epub etc."
s.description  = <<-DESC
A book reader support txt/epub. Just enjoy!
DESC
s.homepage     = "https://github.com/labi3285/QXBookReader"
s.license      = "MIT"
s.author       = { "labi3285" => "766043285@qq.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/labi3285/QXBookReader.git", :tag => "#{s.version}" }
s.source_files = "QXBookReader/QXBookReader/*"

s.resources = "QXBookReader/QXBookReader/QXBookReaderResources.bundle"
s.requires_arc = true

s.frameworks   = "CoreServices", "ImageIO"
s.library = 'sqlite3'

s.dependency 'AEXML',
s.dependency 'SSZipArchive',
s.dependency 'QXMessageView',

# pod trunk push QXBookReader.podspec --allow-warnings

end

