#!/usr/bin/ruby
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
                $ayadn_lastPageID_path = $ayadn_data_path + "/#{$identityPrefix}/.pagination"
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
                $downsideTimeline = $configFileContents['timeline']['downside']
                $skipped_sources = $configFileContents['skipped']['sources']
            else
                # defaults
                $ayadn_data_path = Dir.home + "/ayadn/data"
                $identityPrefix = "me"
                $ayadn_posts_path = $ayadn_data_path + "/#{$identityPrefix}/posts"
                $ayadn_lists_path = $ayadn_data_path + "/#{$identityPrefix}/lists"
                $ayadn_files_path = $ayadn_data_path + "/#{$identityPrefix}/files"
                $ayadn_lastPageID_path = $ayadn_data_path + "/#{$identityPrefix}/.pagination"
                $ayadn_messages_path = $ayadn_data_path + "/#{$identityPrefix}/messages"
                $ayadn_authorization_path = $ayadn_data_path + "/#{$identityPrefix}/.auth"
                $countGlobal = $countUnified = $countCheckins = $countExplore = $countMentions = $countStarred = 100
                $directedPosts = true
                $countStreamBack = 30
                $countdown_1 = 5
                $countdown_2 = 15
                $downsideTimeline = true
                $skipped_sources = []
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
                        lastPageID = f.gets
                    f.close
                else
                    lastPageID = nil
                end
                return lastPageID
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
                            filePath = $ayadn_lastPageID_path + "/lastPageID-#{content}-#{option}"
                            if File.exists?(filePath)
                                FileUtils.rm_rf(filePath)
                                puts "\nDone!\n\n".green
                            else
                                puts "\nAlready done: no #{content} pagination value for #{option} was found.\n\n".green
                            end
                        else
                            puts "\nResetting the pagination for #{content}.\n".red
                            filePath = $ayadn_lastPageID_path + "/lastPageID-#{content}"
                            if File.exists?(filePath)
                                FileUtils.rm_rf(filePath)
                                puts "\nDone!\n\n".green
                            else
                                puts "\nAlready done: no #{content} pagination value was found.\n\n".green
                            end
                        end
                    else
                        puts "\nResetting all pagination data.\n".red
                        Dir["#{$ayadn_lastPageID_path}/*"].each do |file|
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

		def colorize(contentText)
			content = Array.new
			splitted = contentText.split(" ")
			splitted.each do |word|
				if word =~ /^#\w/
                    new_word = removeEndCharIfSpecial(word, "pink")
                    content.push(new_word)
				elsif word =~ /^@\w/
                    new_word = removeEndCharIfSpecial(word, "red")
					content.push(new_word)
				elsif word =~ /^http/ or word =~ /^photos.app.net/ or word =~ /^files.app.net/ or word =~ /^chimp.li/ or word =~ /^bli.ms/
					content.push(word.magenta)
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
        def helpScreen
            help = ""
            help += "- " + "without options: ".green + "display your unified stream\n"
            help += "- " + "write ".green + "+ [Enter key], or " + "write \"your text\" ".green + "to create a post\n"
            help += "- " + "reply postID ".green + "to reply to a post\n"
            help += "- " + "delete postID ".green + "to delete a post\n"
            help += "- " + "pm @username ".green + "to send a private message\n"
            help += "- " + "messages (channelID) ".green + "to display (a channel's) private messages\n"
            help += "- " + "search word(s) ".green + "to search for word(s) (separate words with a comma)\n"
            help += "- " + "tag hashtag ".green + "to search for a hashtag (don't write the '#')\n"
            help += "- " + "star/unstar postID ".green + "to star/unstar a post\n"
            help += "- " + "repost/unrepost postID ".green + "to repost/unrepost a post\n"
            help += "- " + "infos @username/postID ".green + "to display detailed informations on a user or a post\n"
            help += "- " + "convo postID ".green + "to display the conversation around a post\n"
            help += "- " + "posts @username ".green + "to display a user's posts\n"
            help += "- " + "mentions @username ".green + "to display posts mentionning a user\n"
            help += "- " + "starred @username/postID ".green + "to display a user's starred posts / who starred a post\n"
            help += "- " + "reposted postID ".green + "to display who reposted a post\n"
            help += "- " + "interactions ".green + "to display a stream of your interactions\n"
            help += "- " + "global/trending/checkins/conversations ".green + "to display one of these streams\n"
            help += "- " + "follow/unfollow @username ".green + "to follow/unfollow a user\n"
            help += "- " + "mute/unmute @username ".green + "to mute/unmute a user\n"
            #help += "- " + "save/load postID ".green + "to save/load a post locally\n"
            #help += "- " + "list/backup followings/followers/muted @username/me ".green + "to list/backup users you're following, who follow you, that you've muted\n"
            help += "- " + "help ".green + "to display this screen, " + "webhelp ".green + "for more commands, detailed instructions, examples..." + "\n\n"
            #help += "- some options have a one-letter shortcut: w(rite), r(eply), s(earch), p(osts), m(entions), t(ag), c(onvo), i(nfos), h(elp)\n"
            help += "- tip: put 'scroll' before a stream to use the scrolling feature\n\n"
            help += "Examples:\n".cyan
            help += "ayadn.rb ".green + "(display your Unified stream)\n"
            help += "ayadn.rb write ".green + "(write a post with a compose window)\n"
            help += "ayadn.rb write \'@ericd Good morning Eric!\' ".green + "(write a post instantly between double quotes)\n"
            help += "ayadn.rb reply 14805036 ".green + "(reply to post n°14805036 with a compose window)\n"
            help += "ayadn.rb tag nowplaying ".green + "(search for hashtag #nowplaying)\n"
            help += "ayadn.rb star 14805036 ".green + "(star post n°14805036)\n"
            help += "ayadn.rb checkins ".green + "(display the Checkins stream)\n"
            help += "ayadn.rb follow @ayadn ".green + "(follow user @ericd)\n"
            help += "ayadn.rb search ruby,json ".green + "(search for posts with these words)\n"
            help += "ayadn.rb scroll global ".green + "(scroll the global stream)\n"
            help += "\n"
            return help
        end
	end
end