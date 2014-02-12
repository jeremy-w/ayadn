Gem::Specification.new do |s|
  s.name        = 'ayadn'
  s.version     = '0.0.0'
  s.executables << 'ayadn'
  s.required_ruby_version = '>= 2.0.0'
  s.date        = '2014-02-11'
  s.summary     = "App.net command-line client in Ruby"
  s.description = <<EOS
AyaDN has ADN post, PM, and files support. Additionally, it can save post
links to Pinboard, post your currently-playing iTunes song, and backup data
associated with your ADN account, such as followings, followers, and muted
users.
EOS
  s.authors     = ["Eric Dejonckheere"]
  s.email       = 'eric@aya.io'
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.homepage    = 'http://www.ayadn-app.net/'
  s.license     = 'ISC'
end
