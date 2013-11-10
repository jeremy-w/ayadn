# encoding: utf-8
class AyaDN
	class AppdotnetSendPost
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@token = token
		end
		def createPost(text)
			uri = URI("#{@url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"

			payload = {
				"text" => "#{text}"
			}.to_json

			response = https.request(request, payload)
			callback = response.body

			blob = JSON.parse(callback)
			adnData = blob['data']
			resp = buildUniquePost(adnData)
			return resp
		end
		def composePost
			$stdout.sync = true
			i = 0
			maxChar = 256
			numChar = 256
			text = ""
			print "\n\r#{numChar}".brown + " -> "
			while i < maxChar
				input = STDIN.getch
				text += input
				i += 1
				numChar -= 1
				print "\r#{numChar}".brown + " -> ".green + "#{text}"
				if input == "\r"
					puts "\n"
					client = AyaDN::AppdotnetSendPost.new(@token)
					puts client.createPost(text)
					exit
				elsif input == "\e"
					abort("\n\nAnnulation.".reverse_color + " Votre post n'a pas été envoyé.\n\n".red)
				elsif input == "\177"
					text = text[0...-2]
					numChar += 2
					print "\n\r#{numChar}".brown + " -> ".green + "#{text}"
				# elsif 
					# fleches clavier à ignorer	
				end
			end
		end
	end
end






