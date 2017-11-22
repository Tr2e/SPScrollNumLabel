Pod::Spec.new do |s|

  s.name         = "SPScrollNumLabel"
  s.version      = "0.0.1"
  s.summary      = "For Number Scroll Animation with UILabel in iOS"

  s.description  = <<-DESC
       方便快速的实现点赞数字动画等，支持increase及decrease操作，同时支持直接赋值的动画。当然，作为一个UILabel的子类，必须支持common mode，你可以把他当做普通UILabel来用，不过好像没什么必要。
                   DESC

  s.homepage     = "https://github.com/Tr2e/SPScrollNumLabel"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Tr2e" => "tr2e@sina.com" }
  s.platform     = :ios,'8.0'

  s.source       = { :git => "https://github.com/Tr2e/SPScrollNumLabel.git", :tag => "#{s.version}" }
  s.source_files = "SPScrollNumLabel/*.{h,m}"
  s.framework    = 'UIKit'
  s.requires_arc = true
end
