#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class API
		def initialize(token)
			@token = token
			@endpoints = AyaDN::Endpoints.new(@token)
		end
		def makeAuthorizeURL
			@endpoints.authorize_url
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

		def getHash
			response = clientHTTP("get", @url)  
			theHash = JSON.parse(response.body)
		end

		def checkLastPageID(last_page_id)
			@url += "&since_id=#{last_page_id}" if last_page_id != nil
		end

		def getGlobal(last_page_id)
			@url = @endpoints.global
			@url += @endpoints.light_params
			@url += @endpoints.include_directed
			checkLastPageID(last_page_id)
			getHash
		end	
		def getUnified(last_page_id)
			@url = @endpoints.unified
			@url += @endpoints.base_params
			@url += @endpoints.include_directed
			checkLastPageID(last_page_id)
			getHash
		end
		def getSimpleUnified
			@url = @endpoints.unified
			@url += @endpoints.light_params
			@url += @endpoints.include_directed
			getHash
		end
		def getInteractions
			@url = @endpoints.interactions
			#checkLastPageID(last_page_id)
			getHash
		end
		def getHashtags(tag)
			@url = @endpoints.hashtags(tag)
			getHash
		end
		def getExplore(stream, last_page_id)
			@url = @endpoints.explore(stream)
			@url += @endpoints.base_params
			checkLastPageID(last_page_id)
			getHash
		end
		def getUserMentions(username, last_page_id)
			@url = @endpoints.mentions(username)
			@url += @endpoints.light_params
			checkLastPageID(last_page_id)
			getHash
		end
		def getUserPosts(username, last_page_id)
			@url = @endpoints.posts(username)
			@url += @endpoints.base_params
			checkLastPageID(last_page_id)
			getHash
		end
		def getUserInfos(username)
			@url = @endpoints.user_info(username)
			@url += @endpoints.light_params
			getHash
		end
		def getWhoReposted(post_id)
			@url = @endpoints.who_reposted(post_id)
			@url += @endpoints.light_params
			getHash
		end
		def getWhoStarred(post_id)
			@url = @endpoints.who_starred(post_id)
			@url += @endpoints.light_params
			getHash
		end
		def getPostInfos(action, post_id)
			@url = @endpoints.single_post(post_id)
			@url += @endpoints.base_params
			if action == "call"
				getHash
			elsif action == "load"
				fileContent = {}
				File.open("#{$ayadn_posts_path}/#{post_id}.post", "r") do |f|
					fileContent = f.gets
				end
				theHash = eval(fileContent)
			else
				abort($tools.errorSyntax)
			end
		end
		def getSinglePost(post_id)
			@url = @endpoints.single_post(post_id)
			@url += @endpoints.base_params
			getHash
		end
		def getStarredPosts(username)
			@url = @endpoints.starred_posts(username)
			@url += @endpoints.light_params
			getHash
		end
		def getPostReplies(post_id)
			@url = @endpoints.replies(post_id)
			@url += @endpoints.light_params
			getHash
		end
		def getPostMentions(post_id)
			@url = @endpoints.single_post(post_id)
			@url += @endpoints.light_params
			theHash = getHash
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
		def getUserName(username)
			@url = @endpoints.user_info(username)
			@url += @endpoints.light_params
			theHash = getHash
			userInfo = theHash['data']
			userName = userInfo['username']
		end
		def goDelete(post_id)
			@url = @endpoints.single_post(post_id)
			@url += @endpoints.light_params
			isTherePost, isYours = ifExists(post_id)
			return isTherePost, isYours
		end
		def starPost(post_id)
			@url = @endpoints.star(post_id)
			@url += @endpoints.light_params
			httpPost(@url)
		end
		def unstarPost(post_id)
			@url = @endpoints.star(post_id)
			@url += @endpoints.light_params
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def repostPost(post_id)
			@url = @endpoints.repost(post_id)
			@url += @endpoints.light_params
			httpPost(@url)
		end
		def unrepostPost(post_id)
			@url = @endpoints.repost(post_id)
			@url += @endpoints.light_params
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def ifExists(post_id)
			theHash = getHash
			postInfo = theHash['data']
			isTherePost = postInfo['text']
			isYours = postInfo['user']['username']
			return isTherePost, isYours
		end
		def getOriginalPost(post_id)
			theHash = getHash
			postInfo = theHash['data']
			isRepost = postInfo['repost_of']
			goToID = isRepost['id']
		end
		def getUserFollowInfo(username)
			@url = @endpoints.user_info(username)
			@url += @endpoints.light_params
			theHash = getHash
			userInfo = theHash['data']
			youFollow = userInfo['you_follow']
			followsYou = userInfo['follows_you']
			return youFollow, followsYou
		end
		def getUserMuteInfo(username)
			@url = @endpoints.user_info(username)
			@url += @endpoints.light_params
			theHash = getHash
			userInfo = theHash['data']
			youMuted = userInfo['you_muted']
		end
		def muteUser(username)
			@url = @endpoints.mute(username)
			@url += @endpoints.light_params
			httpPost(@url)
		end
		def unmuteUser(username)
			@url = @endpoints.mute(username)
			@url += @endpoints.light_params
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def followUser(username)
			@url = @endpoints.follow(username)
			@url += @endpoints.light_params
			httpPost(@url)
		end
		def unfollowUser(username)
			@url = @endpoints.follow(username)
			@url += @endpoints.light_params
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def getFollowings(username, beforeID)
			@url = @endpoints.following(username)
			@url += @endpoints.light_params
			@url += "&count=200"
			@url += "&before_id=#{beforeID}" if beforeID != nil
			getHash
		end
		def getFollowers(username, beforeID)
			@url = @endpoints.followers(username)
			@url += @endpoints.light_params
			@url += "&before_id=#{beforeID}" if beforeID != nil
			getHash
		end
		def getMuted(username, beforeID)
			@url = @endpoints.muted(username)
			@url += @endpoints.light_params
			@url += "&before_id=#{beforeID}" if beforeID != nil
			getHash
		end
		def getSearch(words)
			@url = @endpoints.search(words)
			@url += @endpoints.light_params
			getHash
		end
		def getUniqueMessage(channel_id, message_id)
			@url = @endpoints.get_message(channel_id, message_id)
			@url += @endpoints.base_params
			getHash
		end
		def getMessages(channel, last_page_id)
			@url = @endpoints.messages(channel)
			@url += @endpoints.base_params
			checkLastPageID(last_page_id)
			getHash
		end
		def getChannels
			@url = @endpoints.channels
			@url += @endpoints.light_params
			getHash
		end
		def getFilesList(beforeID)
			@url = @endpoints.files_list
			@url += @endpoints.light_params
			@url += "&before_id=#{beforeID}" if beforeID != nil
			getHash
		end
		def getSingleFile(file_id)
			@url = @endpoints.get_file(file_id)
			@url += @endpoints.light_params
			getHash
		end
		def getMultipleFiles(file_ids)
			@url = @endpoints.get_multiple_files(file_ids)
			@url += @endpoints.light_params
			getHash
		end
		def deleteFile(file_id)
			@url = @endpoints.get_file(file_id)
			@url += @endpoints.light_params
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def deleteMessage(channel_id, message_id)
			@url = @endpoints.get_message(channel_id, message_id)
			@url += @endpoints.access_token
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
		def deactivateChannel(channel_id)
			@url = CHANNELS_URL + "#{channel_id}?"
			@url += @endpoints.access_token
			resp = clientHTTP("delete")
			$tools.checkHTTPResp(resp)
		end
	end
end