class AyaDN
	class API
		# WIP
		# TESTING DIFFERENT WAYS
		# TODO: DRY
		def clientHTTP(action, target = nil)
			uri = URI("#{@url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			case action
			when "delete"
				request = Net::HTTP::Delete.new(uri.path)
				request["Authorization"] = "Bearer #{@token}"
				request["Content-Type"] = "application/json"
				response = https.request(request)
			when "get"
				uri = URI.parse("#{target}")
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = true
				https.verify_mode = OpenSSL::SSL::VERIFY_NONE
				request = Net::HTTP::Get.new(uri.request_uri)
				request["Authorization"] = "Bearer #{@token}"
				request["Content-Type"] = "application/json"
				
				if $bar_while_scrolling == false # this is ugly but I don't see anything LESS ugly for now
					response = https.request(request)
					return response.body
				else
						print "\rConnecting...".cyan
						body = ''
						https.request(request) do |response| 
							fileSize = response['Content-Length'].to_i
							bytesTransferred = 0
							response.read_body do |part|
								bytesTransferred += part.length
								rounded = bytesTransferred.percent_of(fileSize).round
								print "\rFetching data: ".cyan + "#{rounded.to_s}%".brown
								body << part
							end
						end
						print "\r                           "
						puts ""
						code = JSON.parse(body)
						if code['meta']['code'] == 404
							puts "Does not exist (or has been deleted).\n\n".red
							exit
						end
						return body
				end



			when "download"
				uri = URI("#{target}")
				final_uri = ''
				open(uri) do |h|
				  final_uri = h.base_uri.to_s
				end
				new_uri = URI.parse(final_uri)
				https = Net::HTTP.new(new_uri.host,new_uri.port)
				https.use_ssl = true
				https.verify_mode = OpenSSL::SSL::VERIFY_NONE
				request = Net::HTTP::Get.new(new_uri.request_uri)
				request["Authorization"] = "Bearer #{@token}"
				request["Content-Type"] = "application/json"
				response = https.request(request)
			end
		end
		##### 
		# experimenting
		def createIncompleteFileUpload(file_name) #this part works
			https, request = connectWithHTTP(FILES_URL)
			payload = {
				"kind" => "image",
				"type" => "com.ayadn.files",
				"name" => File.basename(file_name),
				"public" => true
			}.to_json
			response = https.request(request, payload)
			callback = response.body
		end
		def setFileContentUpload(file_id, file_path, file_token) #this one doesn't
			url = FILES_URL + "#{file_id}/content?file_token=#{file_token}"
			uri = URI("#{url}")
			# ...
		end
		#####

		def httpPutFile(file, data) # data must be json
			url = "https://alpha-api.app.net/stream/0/files/#{file}"
			uri = URI("#{url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Put.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"
			response = https.request(request, data)
		end

		def connectWithHTTP(url)
			uri = URI("#{url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"
			return https, request
		end
		def httpPost(url)
			https, request = connectWithHTTP(url)
			response = https.request(request)
		end
		def httpSendMessage(target, text)
			url = PM_URL
			url += "?include_annotations=1"
			https, request = connectWithHTTP(url)
			entities_content = { 
				"parse_markdown_links" => true, 
				"parse_links" => true
			}
			ayadnAnno = clientAnnotations
			destinations = []
			payload = {
				"text" => "#{text}",
				"destinations" => destinations.push(target),
				"entities" => entities_content,
				"annotations" => ayadnAnno
			}.to_json
			response = https.request(request, payload)
			callback = response.body
		end
		def httpSendMessageToChannel(target, text)
			url = CHANNELS_URL
			url += "#{target}/messages"
			#url += "&include_annotations=1"

			https, request = connectWithHTTP(url)
			entities_content = { 
				"parse_markdown_links" => true, 
				"parse_links" => true
			}
			ayadnAnno = clientAnnotations
			destinations = []
			payload = {
				"text" => "#{text}",
				"entities" => entities_content,
				"annotations" => ayadnAnno
			}.to_json
			response = https.request(request, payload)
			callback = response.body
		end
		def httpSend(text, replyto = nil)
			url = POSTS_URL
			url += "?include_annotations=1"
			https, request = connectWithHTTP(url)
			entities_content = { 
					"parse_markdown_links" => true, 
					"parse_links" => true
				}
			ayadnAnno = clientAnnotations
			if replyto == nil
				payload = {
							"text" => "#{text}",
							"entities" => entities_content,
							"annotations" => ayadnAnno
						}.to_json
			else
				payload = {
							"text" => "#{text}",
							"reply_to" => "#{replyto}",
							"entities" => entities_content,
							"annotations" => ayadnAnno
						}.to_json
			end
			response = https.request(request, payload)
			callback = response.body
		end

		def clientAnnotations
			ayadn_annotations = [{
				"type" => "com.ayadn.client",
				"value" => {
		        			"+net.app.core.user" => {
		            			"user_id" => "@ayadn",
		            			"format" => "basic"
			        			}
			        		}
				},{
				"type" => "com.ayadn.client",
				"value" => { "url" => "http://ayadn-app.net" }
				}]
			return ayadn_annotations
		end
	end
end