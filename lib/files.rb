#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class Files
		def initialize
			@token_path = $tools.ayadn_configuration[:authorization_path] + "/token"
			@channels_path = $tools.ayadn_configuration[:messages_path] + "/channels.json"
		end
		def makedir(value)
			unless Dir.exists? value
			    FileUtils.mkdir_p :value
			end
		end
		def get_last_page_id(value)
			if File.exists?(value)
			    f = File.open(value, "r")
			        last_page_id = f.gets
			    f.close
			else
			    last_page_id = nil
			end
			return last_page_id
		end
		def write_last_page_id(value, content)
			f = File.new(value, "w")
			    f.puts(content)
			f.close
		end
		def save_channel_id(value, content)
	        newPrivateChannel = { "#{value}" => "#{content}" }
	        if !File.exists?@channels_path
	            f = File.new(@channels_path, "w")
	                f.puts(newPrivateChannel.to_json)
	            f.close
	        else
	            the_hash = JSON.parse(IO.read(@channels_path)).to_hash
	            the_hash.merge!(newPrivateChannel)
	            f = File.new(@channels_path, "w")
	                f.puts(the_hash.to_json)
	            f.close
	        end
		end
		def load_channels
			JSON.load(IO.read(@channels_path)) if File.exists?@channels_path
		end
		def auth_read
			token = IO.read(@token_path) if File.exists?@token_path
			if token != nil
			    return token.chomp()
			end
		end
		def auth_write(content)
			f = File.new(@token_path, "w")
			    f.puts(content)
			f.close
		end
		def reset_pagination(content = nil, option = nil)
			if content != nil
                if option != nil
                    puts "\nResetting #{content} pagination for #{option}.\n".red
                    filePath = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-#{content}-#{option}"
                    if File.exists?(filePath)
                        FileUtils.rm_rf(filePath)
                        puts "\nDone!\n\n".green
                    else
                        puts "\nAlready done: no #{content} pagination value for #{option} was found.\n\n".green
                    end
                else
                    puts "\nResetting the pagination for #{content}.\n".red
                    filePath = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-#{content}"
                    if File.exists?(filePath)
                        FileUtils.rm_rf(filePath)
                        puts "\nDone!\n\n".green
                    else
                        puts "\nAlready done: no #{content} pagination value was found.\n\n".green
                    end
                end
            else
                puts "\nResetting all pagination data.\n".red
                Dir["#{$tools.ayadn_configuration[:last_page_id_path]}/*"].each do |file|
                    FileUtils.rm_rf file
                end
                puts "\nDone!\n\n".green
            end
		end
		def reset_credentials
            if File.exists?(@token_path)
                 FileUtils.rm_rf(@token_path)
            end
		end
	 	def download_file(file_url, new_file_name, token)
	 		download_file_path = $tools.ayadn_configuration[:files_path] + "/#{new_file_name}"
			if !File.exists?download_file_path
				resp = AyaDN::API.new(token).clientHTTP("download", file_url)
				f = File.new(download_file_path, "wb")
					f.puts(resp.body)
				f.close
				puts "File downloaded in ".green + $tools.ayadn_configuration[:files_path].pink + "/#{new_file_name}".brown + "\n\n"
			else
				puts "Canceled: ".red + "#{new_file_name} ".pink + "already exists in ".red + "#{$tools.ayadn_configuration[:files_path]}".brown + "\n\n"
			end
	 	end
	 	def delete_file(target, token)
	 		JSON.parse(AyaDN::API.new(token).deleteFile(target))
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