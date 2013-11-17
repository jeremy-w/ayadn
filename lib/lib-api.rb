#!/usr/bin/ruby
# encoding: utf-8
class AyaDN
	class API
		def initialize(token)
			@url = 'https://alpha-api.app.net/'
			@token = token
		end
		def getResponse(url)
			begin
				response = RestClient.get(@url)
				return response.body
			rescue => e
				abort("HTTP ERROR :\n".red + "#{e}\n".red)
			end
		end
		def restDelete
			begin
				response = RestClient.delete(@url)
			rescue => e
				abort("HTTP ERROR :\n".red + "#{e}\n".red)
			end
		end
		def httpPost(url)
			uri = URI("#{url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"
			response = https.request(request)
		end
		def httpSend(text, replyto = nil)
			@url = 'https://alpha-api.app.net/'
			@url += 'stream/0/posts'
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
		end
		def getHash
			fromAppdotnet = getResponse(@url)
			theHash = JSON.parse(fromAppdotnet)
		end
		def getGlobal
			@url += 'stream/0/posts/stream/global?access_token='
			@url += @token + '&include_deleted=0'
			@url += '&include_html=0'
			getHash()
		end
		def getUnified
			@url += 'stream/0/posts/stream/unified?access_token='
			@url += @token + '&include_deleted=0'
			@url += '&include_html=0'
			@url += '&include_directed_posts=1'
			getHash()
		end
		def getHashtags(tag)
			@url += 'stream/0/posts/tag/'
			@url += "#{tag}"
			getHash()
		end
		def getExplore(explore)
			@url += 'stream/0/posts/stream/explore/'
			if explore == "checkins"
				@url += "#{explore}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0&include_annotations=1'
			else
				@url += "#{explore}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0'
			end
			getHash()
		end
		def getUserMentions(name)
			@url += 'stream/0/users/'
			@url += "#{name}" 
			@url += "/mentions"
			@url += "/?access_token=#{@token}"
			getHash()
		end
		def getUserPosts(name)
			@url += 'stream/0/users/'
			@url += "#{name}" 
			@url += "/posts"
			@url += "/?access_token=#{@token}"
			@url += '&include_deleted=1&include_html=0'
			getHash()
		end
		def getUserInfos(name)
			@url += 'stream/0/users/'
			@url += "#{name}" 
			@url += "/?access_token=#{@token}"
			getHash()
		end
		def getWhoReposted(postID)
			@url += 'stream/0/posts/'
			@url += "#{postID}" 
			@url += "/reposters"
			@url += "/?access_token=#{@token}"
			getHash()
		end
		def getWhoStarred(postID)
			@url += 'stream/0/posts/'
			@url += "#{postID}" 
			@url += "/stars"
			@url += "/?access_token=#{@token}"
			getHash()
		end
		def getPostInfos(action, postID)
			@url += 'stream/0/posts/'
			@url += "#{postID}" 
			@url += "/?access_token=#{@token}"
			@url += "&include_annotations=1&include_html=0"
			if action == "call"
				getHash()
			elsif action == "load"
				fileContent = Hash.new
				File.open("./data/posts/#{postID}.post", "r") do |f|
					fileContent = f.gets
				end
				theHash = eval(fileContent)
			else
				puts "syntax error".red
				exit
			end
		end
		def getSinglePost(postID)
			@url += 'stream/0/posts/'
			@url += "#{postID}" 
			@url += "/?access_token=#{@token}"
			@url += "&include_annotations=1&include_html=1"
			getHash()
		end
		def getStarredPosts(name)
			@url += 'stream/0/users/'
			@url += "#{name}" 
			@url += "/stars"
			@url += "/?access_token=#{@token}"
			@url += '&include_deleted=0&include_html=0'
			getHash()
		end
		def getPostReplies(postID)
			@url += 'stream/0/posts/'
			@url += "#{postID}" 
			@url += "/replies"
			@url += "/?access_token=#{@token}"
			getHash()
		end
		def getPostMentions(postID)
			@url += 'stream/0/posts/'
			@url += "#{postID}"
			@url += "/?access_token=#{@token}"
			theHash = getHash()
			postInfo = theHash['data']
			userName = postInfo['user']['username']
			rawText = postInfo['text']
			isRepost = postInfo['repost_of']
			return rawText, userName, isRepost
		end
		def getUserName(name)
			@url = 'https://alpha-api.app.net/'
			@url += 'stream/0/users/'
			@url += "#{name}"
			@url += "/?access_token=#{@token}"
			theHash = getHash()
			userInfo = theHash['data']
			userName = userInfo['username']
		end
		def goDelete(postID)
			@url = 'https://alpha-api.app.net/'
			@url += 'stream/0/posts/'
			@url += "/#{postID}" + "/?access_token=#{@token}"
			isTherePost, isYours = ifExists(postID)
			return isTherePost, isYours
		end
		def starPost(postID)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@url += "/#{postID}" + "/star" + "/?access_token=#{@token}"
			httpPost(@url)
		end
		def unstarPost(postID)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@url += "/#{postID}" + "/star" + "/?access_token=#{@token}"
			restDelete()
		end
		def repostPost(postID)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@url += "/#{postID}" + "/repost"  + "/?access_token=#{@token}"
			httpPost(@url)
		end
		def unrepostPost(postID)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@url += "/#{postID}" + "/repost"  + "/?access_token=#{@token}"
			restDelete()
		end
		def ifExists(postID)
			theHash = getHash()
			postInfo = theHash['data']
			isTherePost = postInfo['text']
			isYours = postInfo['user']['username']
			return isTherePost, isYours
		end
		def getOriginalPost(postID)
			theHash = getHash()
			postInfo = theHash['data']
			isRepost = postInfo['repost_of']
			goToID = isRepost['id']
		end
		def getUserFollowInfo(name)
			@url += 'stream/0/users/'
			@url += "#{name}" 
			@url += "/?access_token=#{@token}"
			theHash = getHash()
			userInfo = theHash['data']
			youFollow = userInfo['you_follow']
			followsYou = userInfo['follows_you']
			return youFollow, followsYou
		end
		def followUser(name)
			@url = 'https://alpha-api.app.net/'
			@url += 'stream/0/users/'
			@url += "#{name}"
			@url += "/follow" 
			@url += "/?access_token=#{@token}"
			httpPost(@url)
		end
		def unfollowUser(name)
			@url = 'https://alpha-api.app.net/'
			@url += 'stream/0/users/'
			@url += "#{name}"
			@url += "/follow" 
			@url += "/?access_token=#{@token}"
			restDelete()
		end
	end
end










