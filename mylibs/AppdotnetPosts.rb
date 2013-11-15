# encoding: utf-8
class AyaDN
	class AppdotnetPosts
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@token = token
		end
		def deletePost(postID)
			@url += "/#{postID}" + "/?access_token=#{@token}"
			puts "Deleting post ".cyan + "#{postID}...\n".brown
			puts "Extracting informations...\n".cyan
			clientPostInfo = AyaDN::AppdotnetPostInfo.new(@token)
			isTherePost, isYours = clientPostInfo.ifExists(postID)

			if isTherePost == nil
				puts "Le post a déjà été supprimé.\n\n"
			else
				#if isYours != 
				begin
					response = RestClient.delete(@url)
					#return response.body
					return nil
				rescue
					warnings = ErrorWarning.new
					puts warnings.errorHTTP
				end	
			end
			exit
		end
		def createPost(text, replyto)
			uri = URI("#{@url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"

			if replyto == nil
				payload = {
					"text" => "#{text}"
				}.to_json
			else
				payload = {
					"text" => "#{text}",
					"reply_to" => "#{replyto}"
				}.to_json
			end

			response = https.request(request, payload)
			callback = response.body

			blob = JSON.parse(callback)
			adnData = blob['data']
			builder = AyaDN::BuildPosts.new
			resp = builder.buildUniquePost(adnData)
			return resp
		end
		def composePost(replyto = "", mentionsList = "", myUsername = "")
			# todo: replace all this with a gem or curses or else
			$stdout.sync = true
			maxChar = 256
			charCount = maxChar - mentionsList.length
			text = mentionsList
			print "\n\r#{charCount}".brown + " -> " + text
			while charCount >= 0
				input = STDIN.getch
				text += input
				charCount -= 1
				print "\r#{charCount}".brown + " -> ".green + "#{text}"
				if input == "\r"
					#si touche entrée
					puts "\n\n"
					client = AyaDN::AppdotnetPosts.new(@token)
					puts client.createPost(text, replyto)
					exit
				elsif input == "\e"
					#si touche echapp
					abort("\n\nCanceled.".reverse_color + " Your post hasn't been sent.\n\n".red)
				elsif input == "\177"
					#backspace counts as 1 character as well
					text = text[0...-2]
					charCount += 2
					print "\n\r#{charCount}".brown + " -> ".green + "#{text}"
				#elsif 
					#fleches clavier et autres touches à ignorer	
				end
			end
			warnings = ErrorWarning.new
			puts warnings.errorMaxChars
		end
	end
end






