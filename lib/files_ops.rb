#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class Tools
		def files_ops(action, value, content = nil, option = nil)
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
	end
end