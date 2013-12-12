#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class API
		def initialize(token)
			@url = 'https://alpha-api.app.net/'
			@token = token
			@authorizeURL = "https://account.app.net/oauth/authenticate?client_id=#{AYADN_CLIENT_ID}&response_type=token&redirect_uri=#{AYADN_CALLBACK_URL}&scope=basic stream write_post follow public_messages messages files&include_marker=1"
		end
		def makeAuthorizeURL
			# maybe advanced features later
			@authorizeURL
		end

		##### 
		# experimenting
		def createIncompleteFileUpload(file_name) #this part works
			url = "https://alpha-api.app.net/stream/0/files"
			https, request = connectWithHTTP(url)
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
			url = "https://alpha-api.app.net/stream/0/files/#{file_id}/content?file_token=#{file_token}"
			uri = URI("#{url}")
			#check with the docs to format it properly
			# boundary="AaB03xEd73XiiiZkK"
			# post_body = []
			# post_body << "Content-Type: image/jpeg"
			# post_body << File.read(file_path, "rb")
			# post_body << "--#{boundary}--"
			# https = Net::HTTP.new(uri.host,uri.port)
			# https.use_ssl = true
			# https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			# request = Net::HTTP::Post.new(uri.request_uri)
			# request.body = post_body.join
			# request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"
			# request["Authorization"] = "Bearer #{@token}"
			# puts request.to_s
			# response = https.request(request)
			# puts response.code
			# puts response.body
			# exit
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


		# WIP, todo: DRY
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
				request = Net::HTTP::Get.new(uri.path)
				request["Authorization"] = "Bearer #{@token}"
				request["Content-Type"] = "application/json"
				response = https.request(request)
			when "getlist"
				uri = URI.parse("#{target}")
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = true
				https.verify_mode = OpenSSL::SSL::VERIFY_NONE
				request = Net::HTTP::Get.new(uri.request_uri)
				request["Authorization"] = "Bearer #{@token}"
				request["Content-Type"] = "application/json"
				response = https.request(request)
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
		#

		def httpPost(url)
			https, request = connectWithHTTP(url)
			response = https.request(request)
		end

		def deleteMessage(channel_id, message_id)
			@url = "https://alpha-api.app.net/stream/0/channels/#{channel_id}/messages/#{message_id}"
			@url += "?access_token=#{@token}"
			resp = @api.clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def deactivateChannel(channel_id)
			@url = "https://alpha-api.app.net/stream/0/channels/#{channel_id}"
			@url += "?access_token=#{@token}"
			resp = @api.clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		
		def httpSendMessage(target, text)
			url = 'https://alpha-api.app.net/stream/0/channels/pm/messages'
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
		def httpSend(text, replyto = nil)
			url = 'https://alpha-api.app.net/stream/0/posts'
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
		# def getHash
		# 	response = clientHTTP("get")  
		# 	theHash = JSON.parse(response.body)
		# end
		def getHashNew
			response = clientHTTP("getlist", @url)  
			theHash = JSON.parse(response.body)
		end
		def makeStreamURL(stream, value = nil)
			@url = "https://alpha-api.app.net/"
			case stream
			when "global"
				@url += 'stream/0/posts/stream/global?access_token='
				@url += @token + '&include_deleted=0'
				@url += '&include_html=0'
				@url += "&count=#{$countGlobal}"
			when "unified"
				@url += 'stream/0/posts/stream/unified?access_token='
				@url += @token + '&include_deleted=1'
				@url += '&include_html=0'
				@url += '&include_directed_posts=1' unless $directedPosts == false
				@url += "&count=#{$countUnified}"
			when "simple_unified"
				@url += 'stream/0/posts/stream/unified?access_token='
				@url += @token + '&include_deleted=0'
				@url += '&include_html=0'
				@url += '&include_directed_posts=1' unless $directedPosts == false
				@url += "&count=#{$countStreamBack}"
			when "checkins"
				@url += 'stream/0/posts/stream/explore/'
				@url += "#{stream}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0&include_annotations=1'
				@url += "&count=#{$countCheckins}"
			when "trending", "conversations", "photos"
				@url += 'stream/0/posts/stream/explore/'
				@url += "#{stream}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0'
				@url += "&count=#{$countExplore}"
			when "tag"
				@url += 'stream/0/posts/tag/'
				@url += "#{value}"
			when "mentions"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/mentions"
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
				@url += "&count=#{$countMentions}"
			when "posts"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/posts"
				@url += "/?access_token=#{@token}"
				@url += '&include_deleted=1&include_html=0'
				@url += "&count=#{$countPosts}"
			when "userInfo"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
			when "whoReposted"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/reposters"
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
			when "whoStarred"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/stars"
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
			when "singlePost"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/?access_token=#{@token}"
				@url += "&include_annotations=1&include_html=0"
			when "starredPosts"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/stars"
				@url += "/?access_token=#{@token}"
				@url += '&include_deleted=0&include_html=0'
				@url += "&count=#{$countStarred}"
			when "replies"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/replies"
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
			when "star"
				@url += 'stream/0/posts/'
				@url += "/#{value}" + "/star" + "/?access_token=#{@token}"
			when "repost"
				@url += 'stream/0/posts/'
				@url += "/#{value}" + "/repost"  + "/?access_token=#{@token}"
			when "follow"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/follow" 
				@url += "/?access_token=#{@token}"
			when "followings"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/following" 
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
			when "followers"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/followers" 
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
			when "muted"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/muted" 
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
			when "mute"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/mute" 
				@url += "/?access_token=#{@token}"
			when "search"
				@url += 'stream/0/posts/'
				@url += "search"
				@url += "?text=#{value}"
				@url += "&include_annotations=1"
				@url += "&access_token=#{@token}"
				@url += '&include_html=0'
			when "interactions"
				@url += 'stream/0/users/'
				@url += "me/interactions?"
				@url += "&access_token=#{@token}"
			when "channels"
				@url += "stream/0/channels"
				@url += "?access_token=#{@token}"
			when "files_list"
				@url += "stream/0/users/me/files"
				@url += "?access_token=#{@token}"
			when "get_file"
				@url += "stream/0/files/"
				@url += "#{value}"
				@url += "?access_token=#{@token}"
			when "get_multiple_files"
				@url += "stream/0/files/"
				@url += "?ids=#{value}"
				@url += "&access_token=#{@token}"
			

			end
		end
		def checkLastPageID(last_page_ID = nil)
			@url += "&since_id=#{last_page_ID}" if last_page_ID != nil
		end
		def getUniqueMessage(channel_id, message_id)
			@url = "https://alpha-api.app.net/stream/0/channels/#{channel_id}/messages/#{message_id}?access_token=#{@token}"
			@url += "&include_annotations=1"
			getHashNew
		end
		def getMessages(channel, last_page_ID)
			@url += "stream/0/channels/#{channel}/messages?access_token=#{@token}&count=100"
			@url += "&include_annotations=1"
			checkLastPageID(last_page_ID)
			getHashNew
		end
		def getChannels
			@url = makeStreamURL("channels")
			getHashNew
		end
		def getGlobal(last_page_ID = nil)
			@url = makeStreamURL("global")
			checkLastPageID(last_page_ID)
			getHashNew
		end	
		def getUnified(last_page_ID = nil)
			@url = makeStreamURL("unified")
			checkLastPageID(last_page_ID)
			getHashNew
		end
		def getSimpleUnified
			@url = makeStreamURL("simple_unified")
			getHashNew
		end
		def getInteractions
			@url = makeStreamURL("interactions")
			#checkLastPageID(last_page_ID)
			getHashNew
		end
		def getHashNewtags(tag)
			@url = makeStreamURL("tag", tag)
			getHashNew
		end
		def getExplore(explore, last_page_ID = nil)
			@url = makeStreamURL(explore)
			checkLastPageID(last_page_ID)
			getHashNew
		end
		def getUserMentions(name, last_page_ID = nil)
			@url = makeStreamURL("mentions", name)
			checkLastPageID(last_page_ID)
			getHashNew
		end
		def getUserPosts(name, last_page_ID = nil)
			@url = makeStreamURL("posts", name)
			checkLastPageID(last_page_ID)
			getHashNew
		end
		def getUserInfos(name)
			@url = makeStreamURL("userInfo", name)
			getHashNew
		end
		def getWhoReposted(postID)
			@url = makeStreamURL("whoReposted", postID)
			getHashNew
		end
		def getWhoStarred(postID)
			@url = makeStreamURL("whoStarred", postID)
			getHashNew
		end
		def getPostInfos(action, postID)
			@url = makeStreamURL("singlePost", postID)
			if action == "call"
				getHashNew
			elsif action == "load"
				fileContent = {}
				File.open("#{$ayadn_posts_path}/#{postID}.post", "r") do |f|
					fileContent = f.gets
				end
				theHash = eval(fileContent)
			else
				abort("\nSyntax error\n".red)
			end
		end
		def getSinglePost(postID)
			@url = makeStreamURL("singlePost", postID)
			getHashNew
		end
		def getStarredPosts(name)
			@url = makeStreamURL("starredPosts", name)
			getHashNew
		end
		def getPostReplies(postID)
			@url = makeStreamURL("replies", postID)
			getHashNew
		end
		def getPostMentions(postID)
			@url = makeStreamURL("singlePost", postID)
			theHash = getHashNew
			postInfo = theHash['data']
			userName = postInfo['user']['username']
			#rawText = postInfo['text']
			isRepost = postInfo['repost_of']
			entitiesMentions = postInfo['entities']['mentions']
			postMentionsArray = []
			entitiesMentions.each do |item|
				postMentionsArray.push(item['name'])
			end
			return postMentionsArray, userName, isRepost
		end
		def getUserName(name)
			@url = makeStreamURL("userInfo", name)
			theHash = getHashNew
			userInfo = theHash['data']
			userName = userInfo['username']
		end
		def goDelete(postID)
			@url = makeStreamURL("singlePost", postID)
			isTherePost, isYours = ifExists(postID)
			return isTherePost, isYours
		end
		def starPost(postID)
			@url = makeStreamURL("star", postID)
			httpPost(@url)
		end
		def unstarPost(postID)
			@url = makeStreamURL("star", postID)
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def repostPost(postID)
			@url = makeStreamURL("repost", postID)
			httpPost(@url)
		end
		def unrepostPost(postID)
			@url = makeStreamURL("repost", postID)
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def ifExists(postID)
			theHash = getHashNew
			postInfo = theHash['data']
			isTherePost = postInfo['text']
			isYours = postInfo['user']['username']
			return isTherePost, isYours
		end
		def getOriginalPost(postID)
			theHash = getHashNew
			postInfo = theHash['data']
			isRepost = postInfo['repost_of']
			goToID = isRepost['id']
		end
		def getUserFollowInfo(name)
			@url = makeStreamURL("userInfo", name)
			theHash = getHashNew
			userInfo = theHash['data']
			youFollow = userInfo['you_follow']
			followsYou = userInfo['follows_you']
			return youFollow, followsYou
		end
		def getUserMuteInfo(name)
			@url = makeStreamURL("userInfo", name)
			theHash = getHashNew
			userInfo = theHash['data']
			youMuted = userInfo['you_muted']
		end
		def muteUser(name)
			@url = makeStreamURL("mute", name)
			httpPost(@url)
		end
		def unmuteUser(name)
			@url = makeStreamURL("mute", name)
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def followUser(name)
			@url = makeStreamURL("follow", name)
			httpPost(@url)
		end
		def unfollowUser(name)
			@url = makeStreamURL("follow", name)
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def getFollowings(name, beforeID)
			@url = makeStreamURL("followings", name)
			@url += "&count=200"
			@url += "&before_id=#{beforeID}" if beforeID != nil
			#getHash
			getHashNew
		end
		def getFollowers(name, beforeID)
			@url = makeStreamURL("followers", name)
			@url += "&before_id=#{beforeID}" if beforeID != nil
			#getHash
			getHashNew
		end
		def getMuted(name, beforeID)
			@url = makeStreamURL("muted", name)
			@url += "&before_id=#{beforeID}" if beforeID != nil
			#getHash
			getHashNew
		end
		def getSearch(value)
			@url = makeStreamURL("search", value)
			getHashNew
		end
		def getFilesList(beforeID)
			@url = makeStreamURL("files_list")
			@url += "&before_id=#{beforeID}" if beforeID != nil
			#getHash
			getHashNew
		end
		def getSingleFile(file_id)
			@url = makeStreamURL("get_file", file_id)
			getHashNew
		end
		def getMultipleFiles(file_ids)
			@url = makeStreamURL("get_multiple_files", file_ids)
			#getHash
			getHashNew
		end
		def deleteFile(file_id)
			@url = makeStreamURL("get_file", file_id)
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
	end
end










