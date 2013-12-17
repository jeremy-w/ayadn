#!/usr/bin/env ruby
# encoding: utf-8
class String
    def is_integer?
      self.to_i.to_s == self
    end
end
class Integer
  def to_filesize
    {
      'B'  => 1024,
      'KB' => 1024 * 1024,
      'MB' => 1024 * 1024 * 1024,
      'GB' => 1024 * 1024 * 1024 * 1024,
      'TB' => 1024 * 1024 * 1024 * 1024 * 1024
    }.each_pair { |e, s| return "#{(self.to_f / (s / 1024)).round(2)}#{e}" if self < s }
  end
end

class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end

class AyaDN
	class Tools
        def initialize
            @default_ayadn_data_path = Dir.home + "/ayadn/data"
            @installed_config_path = "#{@default_ayadn_data_path}/config.yml"
            $configFileContents, $loaded = loadConfig
            config
        end
        def loadConfig
            if File.exists?(@installed_config_path)
                configFileContents = YAML::load_file(@installed_config_path)
                loaded = true
            elsif File.exists?('./config.yml')
                configFileContents = YAML::load_file('./config.yml')
                loaded = true
            else
                configFileContents = {}
                loaded = false
            end
            return configFileContents, loaded
        end
        def saveConfig
            if File.exists?(@installed_config_path)
                File.open(@installed_config_path, 'w') {|f| f.write $configFileContents.to_yaml }
                puts "\nDone!\n\n".green
            elsif File.exists?('./config.yml')
                File.open('./config.yml', 'w') {|f| f.write $configFileContents.to_yaml }
                puts "\nDone!\n\n".green
            else
                abort("ERROR FILE NOT FOUND".red)
            end
        end
        def installConfig
            if File.exists?(@installed_config_path)
                puts "\nInstalled config file already exists. Replace with the new one? (N/y) ".red
                input = STDIN.getch
                if input == ("y" || "Y")
                    copyConfigFromMaster
                else
                    abort("\nCanceled.\n\n".red)
                end
            else
                copyConfigFromMaster
            end
        end
        def copyConfigFromMaster
            FileUtils.cp('./config.yml', @installed_config_path)
            puts "\nDone.\n\n".green
        end
        def config
            if $loaded
                $ayadnFiles = $configFileContents['files']['ayadnfiles']
                $identityPrefix = $configFileContents['identity']['prefix']
                $ayadn_data_path = Dir.home + $ayadnFiles
                $ayadn_posts_path = $ayadn_data_path + "/#{$identityPrefix}/posts"
                $ayadn_lists_path = $ayadn_data_path + "/#{$identityPrefix}/lists"
                $ayadn_files_path = $ayadn_data_path + "/#{$identityPrefix}/files"
                $ayadn_last_page_id_path = $ayadn_data_path + "/#{$identityPrefix}/.pagination"
                $ayadn_messages_path = $ayadn_data_path + "/#{$identityPrefix}/messages"
                $ayadn_authorization_path = $ayadn_data_path + "/#{$identityPrefix}/.auth"
                $countGlobal = $configFileContents['counts']['global'].to_i
                $countUnified = $configFileContents['counts']['unified'].to_i
                $countCheckins = $configFileContents['counts']['checkins'].to_i
                $countExplore = $configFileContents['counts']['explore'].to_i
                $countMentions = $configFileContents['counts']['mentions'].to_i
                $countPosts = $configFileContents['counts']['posts'].to_i
                $countStarred = $configFileContents['counts']['starred'].to_i
                $directedPosts = $configFileContents['timeline']['directed']
                $countStreamBack = $configFileContents['timeline']['streamback'].to_i
                $countdown_1 = $configFileContents['timeline']['countdown_1'].to_i
                $countdown_2 = $configFileContents['timeline']['countdown_2'].to_i
                $configShowClient = $configFileContents['timeline']['show_client']
                $downsideTimeline = $configFileContents['timeline']['downside']
                $skipped_sources = $configFileContents['skipped']['sources']
                $skipped_tags = $configFileContents['skipped']['hashtags']
            else
                # defaults
                $ayadn_data_path = Dir.home + "/ayadn/data"
                $identityPrefix = "me"
                $ayadn_posts_path = $ayadn_data_path + "/#{$identityPrefix}/posts"
                $ayadn_lists_path = $ayadn_data_path + "/#{$identityPrefix}/lists"
                $ayadn_files_path = $ayadn_data_path + "/#{$identityPrefix}/files"
                $ayadn_last_page_id_path = $ayadn_data_path + "/#{$identityPrefix}/.pagination"
                $ayadn_messages_path = $ayadn_data_path + "/#{$identityPrefix}/messages"
                $ayadn_authorization_path = $ayadn_data_path + "/#{$identityPrefix}/.auth"
                $countGlobal = $countUnified = $countCheckins = $countExplore = $countMentions = $countStarred = $countPosts = 100
                $directedPosts = true
                $countStreamBack = 30
                $countdown_1 = 5
                $countdown_2 = 15
                $downsideTimeline = true
                $skipped_sources = []
                $skipped_tags = []
                $configShowClient = false
            end
        end

        def fileOps(action, value, content = nil, option = nil)
            case action
            when "makedir"
                unless Dir.exists?value
                    FileUtils.mkdir_p value
                end
            when "getlastpageid"
                if File.exists?(value)
                    f = File.open(value, "r")
                        last_page_id = f.gets
                    f.close
                else
                    last_page_id = nil
                end
                return last_page_id
            when "writelastpageid"
                f = File.new(value, "w")
                    f.puts(content)
                f.close
            when "savechannelid"
                filePath = $ayadn_messages_path + "/pm-channels.json"
                newPrivateChannel = { "#{value}" => "#{content}" }
                if !File.exists?filePath
                    f = File.new(filePath, "w")
                        f.puts(newPrivateChannel.to_json)
                    f.close
                else
                    oldJson = JSON.parse(IO.read(filePath))
                    oldHash = oldJson.to_hash
                    oldHash.merge!(newPrivateChannel)
                    newJson = oldHash.to_json
                    f = File.new(filePath, "w")
                        f.puts(newJson)
                    f.close
                end
            when "loadchannels"
                filePath = $ayadn_messages_path + "/pm-channels.json"
                channels = JSON.load(IO.read(filePath)) if File.exists?filePath
            when "auth"
                filePath = $ayadn_authorization_path + "/token"
                if value == "read"
                    token = IO.read(filePath) if File.exists?filePath
                    if token != nil
                        return token.chomp()
                    end
                elsif value == "write"
                    f = File.new(filePath, "w")
                        f.puts(content)
                    f.close
                end 
            when "reset"
                if value == "pagination"
                    if content != nil
                        if option != nil
                            puts "\nResetting #{content} pagination for #{option}.\n".red
                            filePath = $ayadn_last_page_id_path + "/last_page_id-#{content}-#{option}"
                            if File.exists?(filePath)
                                FileUtils.rm_rf(filePath)
                                puts "\nDone!\n\n".green
                            else
                                puts "\nAlready done: no #{content} pagination value for #{option} was found.\n\n".green
                            end
                        else
                            puts "\nResetting the pagination for #{content}.\n".red
                            filePath = $ayadn_last_page_id_path + "/last_page_id-#{content}"
                            if File.exists?(filePath)
                                FileUtils.rm_rf(filePath)
                                puts "\nDone!\n\n".green
                            else
                                puts "\nAlready done: no #{content} pagination value was found.\n\n".green
                            end
                        end
                    else
                        puts "\nResetting all pagination data.\n".red
                        Dir["#{$ayadn_last_page_id_path}/*"].each do |file|
                            FileUtils.rm_rf file
                        end
                        puts "\nDone!\n\n".green
                    end
                elsif value == "credentials"
                    filePath = $ayadn_authorization_path + "/token"
                    if File.exists?(filePath)
                         FileUtils.rm_rf(filePath)
                    end
                end
            end
        end
        def uploadFiles(file, token)
            file_ext = File.extname(file).downcase
            case file_ext
            when ".png"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=image/png" -X POST`
            when ".gif"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=image/gif" -X POST`
            when ".json",".txt",".md",".markdown",".mdown",".html",".css",".scss",".sass",".jade",".rb",".py",".sh",".js",".xml",".csv"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=text/plain" -X POST`
            when ".zip"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=application/zip" -X POST`
            when ".rar"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=application/rar" -X POST`
            when ".mp4"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=video/mp4" -X POST`
            when ".mov"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=video/quicktime" -X POST`
            when ".mkv",".mp3",".m4a",".m4v",".wav",".aif",".aiff",".aac",".flac"
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=application/octet-stream" -X POST`
            else
                resp = `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F content=@#{file} -X POST`
            end 
        end

		def colorize(contentText)
			content = Array.new
			splitted = contentText.split(" ")
			for word in splitted do
				if word =~ /^#\w/
                    new_word = removeEndCharIfSpecial(word, "pink")
                    content.push(new_word)
				elsif word =~ /^@\w/
                    new_word = removeEndCharIfSpecial(word, "red")
					content.push(new_word)
				#elsif word =~ /^http/ or word =~ /^photos.app.net/ or word =~ /^files.app.net/ or word =~ /^chimp.li/ or word =~ /^bli.ms/
					#content.push(word.magenta)
				else
					content.push(word)
				end
			end
			coloredPost = content.join(" ")
		end
        def removeEndCharIfSpecial(word, color)
            word_array = word.chars.to_a
            last_char = word_array.last
            if last_char =~ /[.,:;?!-'`&"()\/]/
                word_array.pop
                word_without_special_char = word_array.join("")
                if color == "red"
                    word_colored = word_without_special_char.red
                elsif color == "pink"
                    word_colored = word_without_special_char.pink
                end
                new_array = word_colored.chars.to_a
                new_array.push(last_char)
                word = new_array.join("")
            else
                if color == "red"
                    word = word.red
                elsif color == "pink"
                    word = word.pink
                end
            end
        end

        def getMarkdownText(str)
          str.gsub %r{
            \[         # Literal opening bracket
              (        # Capture what we find in here
                [^\]]+ # One or more characters other than close bracket
              )        # Stop capturing
            \]         # Literal closing bracket
            \(         # Literal opening parenthesis
              (        # Capture what we find in here
                [^)]+  # One or more characters other than close parenthesis
              )        # Stop capturing
            \)         # Literal closing parenthesis
          }x, '\1'
        end
        def withoutSquareBraces(str)
            str.gsub %r{
            \[         # Literal opening bracket
              (        # Capture what we find in here
                [^\]]+ # One or more characters other than close bracket
              )        # Stop capturing
            \]         # Literal closing bracket
          }x, ''
        end
        def countdown(value)
            value.downto(1) do |i|
                print "\r#{sprintf("%02d", i)} sec... QUIT WITH [CTRL+C]".cyan
                sleep 1
            end
        end
        def startBrowser(url)
            # thanks to https://github.com/veenstra
            command = case RbConfig::CONFIG['host_os'] 
              when /darwin/ then "open '#{url}'"
            end
            command = "sleep 1; #{command}"
            pid = Process.spawn(command)
            Process.detach(pid)
        end
        def meta(meta)
            case meta['code']
            when 200
                puts "\nDone!\n".green
            when 301,302
                puts "\nRedirected.\n\n".red
                puts "#{meta.inspect}\n".red
            when 404
                puts "Does not exist (or has been deleted).\n\n".red
                exit
            else
                abort("\nERROR: #{meta.inspect}\n".red)
            end
        end
        def checkHTTPResp(resp)
            case resp.code
            when !200
                abort("\nERROR: #{resp.code} #{resp.body}\n".red)
            end
        end
        def saveToPinboard(post_id, pin_username, pin_password, link, tags, post_text, user_name)
            tags << ",ADN"
            post_text << " http://alpha.app.net/#{user_name}/post/#{post_id}"
            pinboard = Pinboard::Client.new(:username => pin_username, :password => pin_password)
            pinboard.add(:url => link, :tags => tags, :extended => post_text, :description => link)
        end
        def helpScreen
            help = "USAGE: ".cyan + "ayadn ".pink + "+ " + "optional action ".green + "+ " + "optional target(s) ".green + "+ " + "optional value(s)\n\n".green
            help << "- " + "without options: ".cyan + "\tdisplay your unified stream\n" #.rjust(50)
            help << "- " + "write ".green + "+ [Enter key] ".magenta + "\tcreate a post\n" #.rjust(33)
            help << "- " + "write ".green + "\"your text\" ".brown + "\tcreate a post\n" #.rjust(35)
            help << "- " + "reply ".green + "PostID ".brown + "\t\treply to a post\n" #.rjust(42)
            help << "- " + "infos, delete, star/unstar, repost/unrepost, convo, starred, reposted ".green + "PostID\n".brown
            # help << "- " + "delete postID ".green + "to delete a post\n"
            help << "- " + "pm ".green + "@username ".brown + "\t\tsend a private message\n"
            help << "- " + "messages ".green + "\t\tdisplay private channels\n"
            help << "- " + "messages ".green + "channelID ".brown + "\tdisplay private messages\n"
            help << "- " + "search ".green + "word ".brown + "\t\tsearch for word(s)\n"
            help << "- " + "tag ".green + "hashtag ".brown + "\t\tsearch for a hashtag\n"
            # help << "- " + "star/unstar postID ".green + "to star/unstar a post\n"
            # help << "- " + "repost/unrepost postID ".green + "to repost/unrepost a post\n"
            # help << "- " + "infos @username/postID ".green + "to display detailed informations on a user or a post\n"
            # help << "- " + "convo postID ".green + "to display the conversation around a post\n"
            help << "- " + "posts ".green + "@username ".brown + "\tdisplay a user's posts\n"
            help << "- " + "mentions ".green + "@username ".brown + "\tdisplay posts mentionning a user\n"
            help << "- " + "infos, starred, follow, unfollow, mute, unmute ".green + "@username\n".brown
            # help << "- " + "starred @username/postID ".green + "to display a user's starred posts / who starred a post\n"
            # help << "- " + "reposted postID ".green + "to display who reposted a post\n"
            # help << "- " + "interactions ".green + "to display a stream of your interactions\n"
            help << "- " + "global/trending/checkins/conversations/photos ".green + "\tdisplay a stream\n"
            # help << "- " + "follow/unfollow @username ".green + "to follow/unfollow a user\n"
            # help << "- " + "mute/unmute @username ".green + "to mute/unmute a user\n"
            #help << "- " + "save/load postID ".green + "to save/load a post locally\n"
            help << "- " + "list/backup followings/followers/muted ".green + "@username/me ".brown + "\tlist/backup users\n"
            #help << "- " + "help ".green + "\t\t\tdisplay this screen\n" 
            help << "- " + "Visit http://github.com/ericdke/ayadn for more commands, options and examples".cyan + "\n\n"
            #help << "- " + "tip: ".cyan + "some commands have a shortcut: w(rite), r(eply), s(earch), p(osts), m(entions), t(ag), c(onvo), i(nfos), h(elp)\n"
            help << "- " + "Tip: put 'scroll' before a stream to use the scrolling feature\n\n".cyan
            help << "Examples:\n\n".cyan
            help << "ayadn \n"#.green + "(display your Unified stream)\n"
            help << "ayadn write \n"#.green + "(write a post with a compose window)\n"
            help << "ayadn write \'@ayadn Posting with AyaDN!\' \n"#.green + "(write a post instantly between double quotes)\n"
            help << "ayadn reply 14805036 \n"#.green + "(reply to post n°14805036 with a compose window)\n"
            help << "ayadn tag nowplaying \n"#.green + "(search for hashtag #nowplaying)\n"
            help << "ayadn star 14805036 \n"#.green + "(star post n°14805036)\n"
            help << "ayadn checkins \n"#.green + "(display the Checkins stream)\n"
            help << "ayadn follow @ayadn \n"#.green + "(follow user @ericd)\n"
            help << "ayadn search ruby,json \n"#.green + "(search for posts with these words)\n"
            help << "ayadn list files \n"
            help << "ayadn backup followings me \n"
            help << "\n"
            return help
        end
	end
end