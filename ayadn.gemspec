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
  s.files       = %w(lib/ayadn.rb
                     lib/ayadn/adn_files.rb
                     lib/ayadn/api.rb
                     lib/ayadn/authorize.rb
                     lib/ayadn/client-http.rb
                     lib/ayadn/colors.rb
                     lib/ayadn/debug.rb
                     lib/ayadn/endpoints.rb
                     lib/ayadn/extend.rb
                     lib/ayadn/files.rb
                     lib/ayadn/get-api.rb
                     lib/ayadn/help.rb
                     lib/ayadn/list.rb
                     lib/ayadn/main.rb
                     lib/ayadn/pinboard.rb
                     lib/ayadn/post.rb
                     lib/ayadn/requires.rb
                     lib/ayadn/skip.rb
                     lib/ayadn/status.rb
                     lib/ayadn/tools.rb
                     lib/ayadn/user-stream.rb
                     lib/ayadn/view-channels.rb
                     lib/ayadn/view-interactions.rb
                     lib/ayadn/view-object.rb
                     lib/ayadn/view.rb)
  s.homepage    = 'http://www.ayadn-app.net/'
  s.license     = 'ISC'
end
