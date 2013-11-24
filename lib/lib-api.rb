#!/usr/bin/ruby
# encoding: utf-8
class AyaDN
	class API
		def initialize(token)
			@url = 'https://alpha-api.app.net/'
			@token = token
			@tools = AyaDN::Tools.new
			@countGlobal, @countUnified, @countCheckins, @countExplore, @countMentions, @countPosts, @countStarred = 100
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
			anno = "?include_annotations=1"
			uri = URI("#{@url}#{anno}")
			#uri = URI("#{@url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"
			ent = { 
				"parse_markdown_links" => true, 
				"parse_links" => true
			}
			ayadnAnno = [{
    			"type" => "com.ayadn.appinfo",
				"value" => {
        			"+net.app.core.user" => {
            			"user_id" => "@ayadn",
            			"format" => "full"
        			}
        		}
			}]
			if replyto == nil
				payload = {
					"text" => "#{text}",
					"entities" => ent,
					"annotations" => ayadnAnno
				}.to_json
			else
				payload = {
					"text" => "#{text}",
					"reply_to" => "#{replyto}",
					"entities" => ent,
					"annotations" => ayadnAnno
				}.to_json
			end
			# puts payload.to_s
			# puts uri.to_s
			# exit
			response = https.request(request, payload)
			callback = response.body
		end
		def getHash
			fromAppdotnet = getResponse(@url)
			theHash = JSON.parse(fromAppdotnet)
		end

		def configAPI
			configFileContents, loaded = @tools.loadConfig
			if loaded
				@countGlobal = configFileContents['counts']['global'].to_i
				@countUnified = configFileContents['counts']['unified'].to_i
				@countCheckins = configFileContents['counts']['checkins'].to_i
				@countExplore = configFileContents['counts']['explore'].to_i
				@countMentions = configFileContents['counts']['mentions'].to_i
				@countPosts = configFileContents['counts']['posts'].to_i
				@countStarred = configFileContents['counts']['starred'].to_i
			end
		end

		def makeStreamURL(stream, value = nil)
			@url = "https://alpha-api.app.net/"
			case
			when stream == "global"
				@url += 'stream/0/posts/stream/global?access_token='
				@url += @token + '&include_deleted=0'
				@url += '&include_html=0'
				@url += "&count=#{@countGlobal}"
			when stream == "unified"
				@url += 'stream/0/posts/stream/unified?access_token='
				@url += @token + '&include_deleted=0'
				@url += '&include_html=0'
				@url += '&include_directed_posts=1'
				@url += "&count=#{@countUnified}"
			when stream == "checkins"
				@url += 'stream/0/posts/stream/explore/'
				@url += stream + "?access_token=#{@token}" + '&include_deleted=0&include_html=0&include_annotations=1'
				@url += "&count=#{@countCheckins}"
			when stream == "trending", stream == "conversations", stream == "photos"
				@url += 'stream/0/posts/stream/explore/'
				@url += "#{stream}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0'
				@url += "&count=#{@countExplore}"
			when stream == "tag"
				@url += 'stream/0/posts/tag/'
				@url += "#{value}"
			when stream == "mentions"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/mentions"
				@url += "/?access_token=#{@token}"
				@url += '&include_html=0'
				@url += "&count=#{@countMentions}"
			when stream == "posts"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/posts"
				@url += "/?access_token=#{@token}"
				@url += '&include_deleted=1&include_html=0'
				@url += "&count=#{@countPosts}"
			when stream == "userInfo"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/?access_token=#{@token}"
			when stream == "whoReposted"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/reposters"
				@url += "/?access_token=#{@token}"
			when stream == "whoStarred"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/stars"
				@url += "/?access_token=#{@token}"
			when stream == "singlePost"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/?access_token=#{@token}"
				@url += "&include_annotations=1&include_html=0"
			when stream == "starredPosts"
				@url += 'stream/0/users/'
				@url += "#{value}" 
				@url += "/stars"
				@url += "/?access_token=#{@token}"
				@url += '&include_deleted=0&include_html=0'
				@url += "&count=#{@countStarred}"
			when stream == "replies"
				@url += 'stream/0/posts/'
				@url += "#{value}" 
				@url += "/replies"
				@url += "/?access_token=#{@token}"
			when stream == "star"
				@url += 'stream/0/posts/'
				@url += "/#{value}" + "/star" + "/?access_token=#{@token}"
			when stream == "repost"
				@url += 'stream/0/posts/'
				@url += "/#{value}" + "/repost"  + "/?access_token=#{@token}"
			when stream == "follow"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/follow" 
				@url += "/?access_token=#{@token}"
			when stream == "followings"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/following" 
				@url += "/?access_token=#{@token}"
			when stream == "followers"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/followers" 
				@url += "/?access_token=#{@token}"
			when stream == "muted"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/muted" 
				@url += "/?access_token=#{@token}"
			when stream == "mute"
				@url += 'stream/0/users/'
				@url += "#{value}"
				@url += "/mute" 
				@url += "/?access_token=#{@token}"
			when stream == "search"
				@url += 'stream/0/posts/'
				@url += "search"
				@url += "?text=#{value}"
				@url += "&include_annotations=1"
				@url += "&access_token=#{@token}"

			end
		end
		def checkLastPageID(lastPageID = nil)
			if lastPageID != nil
				@url += "&since_id=#{lastPageID}"
			end
			return @url
		end

		def getGlobal(lastPageID = nil)
			@url = makeStreamURL("global")
			checkLastPageID(lastPageID)
			getHash
		end
		def getUnified(lastPageID = nil)
			@url = makeStreamURL("unified")
			checkLastPageID(lastPageID)
			getHash
		end
		def getHashtags(tag)
			@url = makeStreamURL("tag", tag)
			getHash
		end
		def getExplore(explore, lastPageID = nil)
			@url = makeStreamURL(explore)
			checkLastPageID(lastPageID)
			getHash
		end
		def getUserMentions(name, lastPageID = nil)
			@url = makeStreamURL("mentions", name)
			checkLastPageID(lastPageID)
			getHash
		end
		def getUserPosts(name, lastPageID = nil)
			@url = makeStreamURL("posts", name)
			checkLastPageID(lastPageID)
			getHash
		end
		def getUserInfos(name)
			@url = makeStreamURL("userInfo", name)
			getHash
		end
		def getWhoReposted(postID)
			@url = makeStreamURL("whoReposted", postID)
			getHash
		end
		def getWhoStarred(postID)
			@url = makeStreamURL("whoStarred", postID)
			getHash
		end
		def getPostInfos(action, postID)
			@url = makeStreamURL("singlePost", postID)
			if action == "call"
				getHash
			elsif action == "load"
				fileContent = Hash.new
				File.open("/data/posts/#{postID}.post", "r") do |f|
					fileContent = f.gets
				end
				theHash = eval(fileContent)
			else
				puts "syntax error".red
				exit
			end
		end
		def getSinglePost(postID)
			@url = makeStreamURL("singlePost", postID)
			getHash
		end
		def getStarredPosts(name)
			@url = makeStreamURL("starredPosts", name)
			getHash
		end
		def getPostReplies(postID)
			@url = makeStreamURL("replies", postID)
			getHash
		end
		def getPostMentions(postID)
			@url = makeStreamURL("singlePost", postID)
			theHash = getHash
			postInfo = theHash['data']
			userName = postInfo['user']['username']
			rawText = postInfo['text']
			isRepost = postInfo['repost_of']
			return rawText, userName, isRepost
		end
		def getUserName(name)
			@url = makeStreamURL("userInfo", name)
			theHash = getHash
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
			restDelete
		end
		def repostPost(postID)
			@url = makeStreamURL("repost", postID)
			httpPost(@url)
		end
		def unrepostPost(postID)
			@url = makeStreamURL("repost", postID)
			restDelete
		end
		def ifExists(postID)
			theHash = getHash
			postInfo = theHash['data']
			isTherePost = postInfo['text']
			isYours = postInfo['user']['username']
			return isTherePost, isYours
		end
		def getOriginalPost(postID)
			theHash = getHash
			postInfo = theHash['data']
			isRepost = postInfo['repost_of']
			goToID = isRepost['id']
		end
		def getUserFollowInfo(name)
			@url = makeStreamURL("userInfo", name)
			theHash = getHash
			userInfo = theHash['data']
			youFollow = userInfo['you_follow']
			followsYou = userInfo['follows_you']
			return youFollow, followsYou
		end
		def getUserMuteInfo(name)
			@url = makeStreamURL("userInfo", name)
			theHash = getHash
			userInfo = theHash['data']
			youMuted = userInfo['you_muted']
		end
		def muteUser(name)
			@url = makeStreamURL("mute", name)
			httpPost(@url)
		end
		def unmuteUser(name)
			@url = makeStreamURL("mute", name)
			restDelete
		end
		def followUser(name)
			@url = makeStreamURL("follow", name)
			httpPost(@url)
		end
		def unfollowUser(name)
			@url = makeStreamURL("follow", name)
			restDelete
		end
		def getFollowings(name, beforeID)
			@url = makeStreamURL("followings", name)
			@url += "&count=200"
			if beforeID != nil
				@url += "&before_id=#{beforeID}"
			end
			getHash
		end
		def getFollowers(name, beforeID)
			@url = makeStreamURL("followers", name)
			if beforeID != nil
				@url += "&before_id=#{beforeID}"
			end
			getHash
		end
		def getMuted(name, beforeID)
			@url = makeStreamURL("muted", name)
			if beforeID != nil
				@url += "&before_id=#{beforeID}"
			end
			getHash
		end
		def getSearch(value)
			@url = makeStreamURL("search", value)
			getHash
		end
	end
end










