Pod::Spec.new do |s|
  s.name         = "ZLMusicFlowWaveView"
  s.version      = "0.0.1"
  s.summary      = "A ZLSinusWaveView subclass inspired by 乐流/MusicFlow"
  s.description  = <<-DESC
                   A [ZLSinusWaveView](https://github.com/zhxnlai/ZLSinusWaveView) subclass inspired by 乐流/MusicFlow
                   DESC
  s.homepage     = "https://github.com/zhxnlai/ZLMusicFlowWaveView"
  s.screenshots  = "https://raw.githubusercontent.com/zhxnlai/ZLMusicFlowWaveView/master/Previews/preview.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Zhixuan Lai" => "zhxnlai@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/zhxnlai/ZLMusicFlowWaveView.git", :tag => "0.0.1" }
  s.source_files = "ZLMusicFlowWaveView/*.{h,m}"
  s.requires_arc = true
  s.dependency "ZLSinusWaveView"
end
