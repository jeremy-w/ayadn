#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class Tools
        def initialize
            @default_ayadn_data_path = Dir.home + "/ayadn/data"
            @installed_config_path = "#{@default_ayadn_data_path}/config.yml"
            @configFileContents = loadConfig
            identityPrefix = @configFileContents['identity']['prefix']
            ayadn_data_path = Dir.home + @configFileContents['files']['ayadnfiles']  
            @ayadn_configuration = {
                data_path: ayadn_data_path,
                posts_path: ayadn_data_path + "/#{identityPrefix}/posts",
                lists_path: ayadn_data_path + "/#{identityPrefix}/lists",
                files_path: ayadn_data_path + "/#{identityPrefix}/files",
                db_path: ayadn_data_path + "/#{identityPrefix}/db",
                last_page_id_path: ayadn_data_path + "/#{identityPrefix}/.pagination",
                messages_path: ayadn_data_path + "/#{identityPrefix}/messages",
                authorization_path: ayadn_data_path + "/#{identityPrefix}/.auth",
                api_config_path: ayadn_data_path + "/#{identityPrefix}/.api",
                progress_indicator: false,
                platform: RbConfig::CONFIG['host_os'] 
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
                        "show_symbols" => true,
                        "show_reposters" => false
                    },
                    "files" => { 
                        "ayadnfiles" => "/ayadn/data",
                        "auto_save_sent_messages" => false,
                        "auto_save_sent_posts" => false
                    },
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
            else
                File.open('./config.yml', 'w') {|f| f.write config.to_yaml }
                puts "\nDone!\n\n".green
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
        def winplatforms
            /mswin|mingw|mingw32|cygwin/
        end
		def colorize(contentText)
			content = Array.new
			for word in contentText.split(" ") do
				if word =~ /#\w+/
                    content.push(word.gsub(/#([A-Za-z0-9_]{1,255})(?![\w+])/, '#\1'.pink))
                    #content.push(removeEndCharIfSpecial(word, "pink"))
				elsif word =~ /@\w+/ 
                    content.push(word.gsub(/@([A-Za-z0-9_]{1,20})(?![\w+])/, '@\1'.red))
					#content.push(removeEndCharIfSpecial(word, "red"))
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
                if color == "red"
                    word_colored = word_array.join("").red
                elsif color == "pink"
                    word_colored = word_array.join("").pink
                end
                word_colored.chars.to_a.push(last_char).join("")
            else
                if color == "red"
                    word.red
                elsif color == "pink"
                    word.pink
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
            Process.detach(Process.spawn("sleep 1; open '#{url}'"))
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
	end
end