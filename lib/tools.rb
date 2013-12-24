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
            @configFileContents = loadConfig
            identityPrefix = @configFileContents['identity']['prefix']
            ayadn_data_path = Dir.home + @configFileContents['files']['ayadnfiles']  
            @ayadn_configuration = {
                :data_path => ayadn_data_path,
                :posts_path => ayadn_data_path + "/#{identityPrefix}/posts",
                :lists_path => ayadn_data_path + "/#{identityPrefix}/lists",
                :files_path => ayadn_data_path + "/#{identityPrefix}/files",
                :last_page_id_path => ayadn_data_path + "/#{identityPrefix}/.pagination",
                :messages_path => ayadn_data_path + "/#{identityPrefix}/messages",
                :authorization_path => ayadn_data_path + "/#{identityPrefix}/.auth",
                :API_config_path => ayadn_data_path + "/#{identityPrefix}/.api",
                :progress_indicator => false
            }
        end
        def loadConfig
            if File.exists?(@installed_config_path)
                YAML::load_file(@installed_config_path)
            elsif File.exists?('./config.yml')
                YAML::load_file('./config.yml')
            else
                {
                    "counts" => {
                        "global" => 100,
                        "unified" => 100,
                        "checkins" => 100,
                        "explore" => 100,
                        "mentions" => 100,
                        "starred" => 100,
                        "posts" => 100
                    },
                    "timeline" => {
                        "downside" => true,
                        "directed" => true,
                        "streamback" => 30,
                        "countdown_1" => 5,
                        "countdown_2" => 15,
                        "show_client" => false,
                        "show_symbols" => true
                    },
                    "files" => { "ayadnfiles" => "/ayadn/data" },
                    "identity" => { "prefix" => "me" },
                    "skipped" => {
                        "sources" => [],
                        "hashtags" => [],
                        "mentions" => []
                    },
                    "pinboard" => {
                        "username" => "",
                        "password" => ""
                    }
                }
            end
        end
        def saveConfig
            if File.exists?(@installed_config_path)
                File.open(@installed_config_path, 'w') {|f| f.write config.to_yaml }
                puts "\nDone!\n\n".green
            elsif File.exists?('./config.yml')
                File.open('./config.yml', 'w') {|f| f.write config.to_yaml }
                puts "\nDone!\n\n".green
            else
                abort("ERROR FILE NOT FOUND".red)
            end
        end
        def installConfig
            if File.exists?(@installed_config_path)
                puts "\nInstalled config file already exists. Replace with the new one? (N/y) ".red
                if STDIN.getch == ("y" || "Y")
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
            @configFileContents
        end
        def ayadn_configuration
            @ayadn_configuration
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
                filePath = ayadn_configuration[:messages_path] + "/channels.json"
                newPrivateChannel = { "#{value}" => "#{content}" }
                if !File.exists?filePath
                    f = File.new(filePath, "w")
                        f.puts(newPrivateChannel.to_json)
                    f.close
                else
                    the_hash = JSON.parse(IO.read(filePath)).to_hash
                    the_hash.merge!(newPrivateChannel)
                    f = File.new(filePath, "w")
                        f.puts(the_hash.to_json)
                    f.close
                end
            when "loadchannels"
                filePath = ayadn_configuration[:messages_path] + "/channels.json"
                JSON.load(IO.read(filePath)) if File.exists?filePath
            when "auth"
                filePath = ayadn_configuration[:authorization_path] + "/token"
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
                            filePath = ayadn_configuration[:last_page_id_path] + "/last_page_id-#{content}-#{option}"
                            if File.exists?(filePath)
                                FileUtils.rm_rf(filePath)
                                puts "\nDone!\n\n".green
                            else
                                puts "\nAlready done: no #{content} pagination value for #{option} was found.\n\n".green
                            end
                        else
                            puts "\nResetting the pagination for #{content}.\n".red
                            filePath = ayadn_configuration[:last_page_id_path] + "/last_page_id-#{content}"
                            if File.exists?(filePath)
                                FileUtils.rm_rf(filePath)
                                puts "\nDone!\n\n".green
                            else
                                puts "\nAlready done: no #{content} pagination value was found.\n\n".green
                            end
                        end
                    else
                        puts "\nResetting all pagination data.\n".red
                        Dir["#{ayadn_configuration[:last_page_id_path]}/*"].each do |file|
                            FileUtils.rm_rf file
                        end
                        puts "\nDone!\n\n".green
                    end
                elsif value == "credentials"
                    filePath = ayadn_configuration[:authorization_path] + "/token"
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
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=image/png" -X POST`
            when ".gif"
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=image/gif" -X POST`
            when ".json",".txt",".md",".markdown",".mdown",".html",".css",".scss",".sass",".jade",".rb",".py",".sh",".js",".xml",".csv"
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=text/plain" -X POST`
            when ".zip"
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=application/zip" -X POST`
            when ".rar"
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=application/rar" -X POST`
            when ".mp4"
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=video/mp4" -X POST`
            when ".mov"
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=video/quicktime" -X POST`
            when ".mkv",".mp3",".m4a",".m4v",".wav",".aif",".aiff",".aac",".flac"
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F "content=@#{file};type=application/octet-stream" -X POST`
            else
                `curl -k -H 'Authorization: BEARER #{token}' https://alpha-api.app.net/stream/0/files -F 'type=com.ayadn.files' -F content=@#{file} -X POST`
            end 
        end

		def colorize(contentText)
			content = Array.new
			for word in contentText.split(" ") do
				if word =~ /#\w+/
                    content.push(removeEndCharIfSpecial(word, "pink"))
				elsif word =~ /@\w+/
					content.push(removeEndCharIfSpecial(word, "red"))
				#elsif word =~ /^http/ or word =~ /^photos.app.net/ or word =~ /^files.app.net/ or word =~ /^chimp.li/ or word =~ /^bli.ms/
					#content.push(word.magenta)
				else
					content.push(word)
				end
			end
			content.join(" ")
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
                abort("\nERROR: #{meta.to_s}\n".red)
            end
        end
        def checkHTTPResp(resp)
            case resp.code
            when !200
                abort("\nERROR: does not exist (or has been deleted) => #{resp.code} #{resp.body}\n".red)
            end
        end
        def saveToPinboard(post_id, pin_username, pin_password, link, tags, post_text, user_name)
            tags += ",ADN"
            post_text += " http://alpha.app.net/#{user_name}/post/#{post_id}"
            pinboard = Pinboard::Client.new(:username => pin_username, :password => pin_password)
            pinboard.add(:url => link, :tags => tags, :extended => post_text, :description => link)
        end
        def helpScreen
            help = "USAGE: ".cyan + "ayadn ".pink + "+ " + "optional action ".green + "+ " + "optional target(s) ".green + "+ " + "optional value(s)\n\n".green
            help << "- " + "without options: ".cyan + "\tdisplay your unified stream\n" #.rjust(50)
            help << "- " + "write ".green + "+ [Enter key] ".magenta + "\tcreate a post\n" #.rjust(33)
            help << "- " + "write ".green + "\"your text\" ".brown + "\tcreate a post\n" #.rjust(35)
            help << "- " + "reply ".green + "PostID ".brown + "\t\treply to a post\n" #.rjust(42)
            # help << "- " + "delete postID ".green + "to delete a post\n"
            help << "- " + "pm ".green + "@username ".brown + "\t\tsend a private message\n"
            help << "- " + "channels ".green + "\t\tdisplay private channels\n"
            help << "- " + "messages ".green + "channelID ".brown + "\tdisplay private messages\n"
            help << "- " + "search ".green + "word ".brown + "\t\tsearch for word(s)\n"
            help << "- " + "tag ".green + "hashtag ".brown + "\t\tsearch for a hashtag\n"
            # help << "- " + "star/unstar postID ".green + "to star/unstar a post\n"
            # help << "- " + "repost/unrepost postID ".green + "to repost/unrepost a post\n"
            # help << "- " + "infos @username/postID ".green + "to display detailed informations on a user or a post\n"
            # help << "- " + "convo postID ".green + "to display the conversation around a post\n"
            help << "- " + "posts ".green + "@username ".brown + "\tdisplay a user's posts\n"
            help << "- " + "mentions ".green + "@username ".brown + "\tdisplay posts mentionning a user\n"
            # help << "- " + "starred @username/postID ".green + "to display a user's starred posts / who starred a post\n"
            # help << "- " + "reposted postID ".green + "to display who reposted a post\n"
            # help << "- " + "interactions ".green + "to display a stream of your interactions\n"
            help << "- " + "global/trending/checkins/conversations/photos ".green + "\tdisplay a stream\n"
            # help << "- " + "follow/unfollow @username ".green + "to follow/unfollow a user\n"
            # help << "- " + "mute/unmute @username ".green + "to mute/unmute a user\n"
            #help << "- " + "save/load postID ".green + "to save/load a post locally\n"
            help << "- " + "list/backup followings/followers/muted ".green + "@username/me ".brown + "\tlist/backup users\n"
            help << "- " + "infos, delete, star/unstar, repost/unrepost, convo, starred, reposted ".green + "PostID\n".brown
            help << "- " + "infos, starred, follow, unfollow, mute, unmute ".green + "@username\n".brown
            #help << "- " + "help ".green + "\t\t\tdisplay this screen\n" 
            help << "- " + "help/commands/webhelp".green + "\n\n"
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
            help << "ayadn scroll global \n"
            help << "ayadn follow @ayadn \n"#.green + "(follow user @ericd)\n"
            help << "ayadn search ruby,json \n"#.green + "(search for posts with these words)\n"
            #help << "ayadn list files \n"
            help << "ayadn backup followings me \n"
            help << "\n"
            return help
        end
        def list_of_commands
            commands = "\nList of commands: \n\n".cyan
            commands << "ayadn\n"
            commands << "ayadn scroll\n"
            commands << "ayadn write\n"
            commands << "ayadn write '@ericd Good morning Eric!'\n"
            commands << "ayadn reply 15723266\n"
            commands << "ayadn pm @ericd\n"
            commands << "ayadn global\n"
            commands << "ayadn scroll global\n"
            commands << "ayadn checkins\n"
            commands << "ayadn scroll checkins\n"
            commands << "ayadn trending\n"
            commands << "ayadn scroll trending\n"
            commands << "ayadn photos\n"
            commands << "ayadn scroll photos\n"
            commands << "ayadn conversations\n"
            commands << "ayadn scroll conversations\n"
            commands << "ayadn mentions @ericd\n"
            commands << "ayadn scroll mentions @ericd\n"
            commands << "ayadn posts @ericd\n"
            commands << "ayadn scroll posts @ericd\n"
            commands << "ayadn starred @ericd\n"
            commands << "ayadn starred 15723266\n"
            commands << "ayadn reposted 15723266\n"
            commands << "ayadn infos @ericd\n"
            commands << "ayadn infos 15723266\n"
            commands << "ayadn convo 15726105\n"
            commands << "ayadn tag nowplaying\n"
            commands << "ayadn follow @ericd\n"
            commands << "ayadn unfollow @ericd\n"
            commands << "ayadn mute @ericd\n"
            commands << "ayadn unmute @ericd\n"
            commands << "ayadn interactions\n"
            commands << "ayadn list files\n"
            commands << "ayadn list files all\n"
            commands << "ayadn download 286458\n"
            commands << "ayadn download 286458,286797\n"
            commands << "ayadn upload /path/to/kitten.jpg\n"
            commands << "ayadn private 286458\n"
            commands << "ayadn public 286458\n"
            commands << "ayadn delete-file 286458\n"
            commands << "ayadn search ruby\n"
            commands << "ayadn search ruby,json\n"
            commands << "ayadn channels\n"
            commands << "ayadn send 12345\n"
            commands << "ayadn messages 12345\n"
            commands << "ayadn messages 12345 all\n"
            commands << "ayadn star 15723266\n"
            commands << "ayadn unstar 15723266\n"
            commands << "ayadn repost 15723266\n"
            commands << "ayadn unrepost 15723266\n"
            commands << "ayadn delete 12345678\n"
            commands << "ayadn list muted\n"
            commands << "ayadn list followings @ericd\n"
            commands << "ayadn list followers @ericd\n"
            commands << "ayadn backup muted\n"
            commands << "ayadn backup followings @ericd\n"
            commands << "ayadn backup followers @ericd\n"
            commands << "ayadn save 15723266\n"
            commands << "ayadn load 15723266\n"
            commands << "ayadn skip-source add IFTTT\n"
            commands << "ayadn skip-source remove IFTTT\n"
            commands << "ayadn skip-source show\n"
            commands << "ayadn skip-tag add sports\n"
            commands << "ayadn skip-tag remove sports\n"
            commands << "ayadn skip-tag show\n"
            commands << "ayadn skip-mention add username\n"
            commands << "ayadn skip-mention remove username\n"
            commands << "ayadn skip-mention show\n"
            commands << "ayadn pin 16864003 ruby,json\n"
            commands << "ayadn reset pagination\n"
            commands << "ayadn help\n"
            commands << "ayadn commands\n"
            commands << "ayadn webhelp\n"
            commands << "ayadn random\n"
            commands << "\n"
            return commands
        end
	end
end