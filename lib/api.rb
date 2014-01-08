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

		def getHash
			JSON.parse(clientHTTP("get", @url))
		end

		def checkLastPageID(last_page_id)
			@url += "&since_id=#{last_page_id}" if last_page_id != nil
		end

		def getAPIConfig
			@url = CONFIG_API_URL
			getHash
		end

		def getGlobal(last_page_id)
			@url = @endpoints.global
			@url += @endpoints.light_params
			@url += @endpoints.include_directed if $tools.config['timeline']['directed']
			checkLastPageID(last_page_id)
			getHash
		end	
		def getUnified(last_page_id)
			@url = @endpoints.unified
			@url += @endpoints.base_params
			@url += @endpoints.include_directed if $tools.config['timeline']['directed']
			checkLastPageID(last_page_id)
			getHash
		end
		def getSimpleUnified
			@url = @endpoints.unified_streamback
			@url += @endpoints.base_params
			@url += @endpoints.include_directed if $tools.config['timeline']['directed']
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
			@url += @endpoints.base_params
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
		def getPostInfos(post_id)
			@url = @endpoints.single_post(post_id)
			@url += @endpoints.base_params
			getHash
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
			@url += @endpoints.base_params
			getHash
		end
		def getPostMentions(post_id)
			@url = @endpoints.single_post(post_id)
			@url += @endpoints.light_params
			theHash = getHash
			postInfo = theHash['data']
			#rawText = postInfo['text']
			postMentionsArray = []
			postInfo['entities']['mentions'].each { |item| postMentionsArray.push(item['name']) }
			return postMentionsArray, postInfo['user']['username'], postInfo['repost_of']
		end
		def getUserName(username)
			@url = @endpoints.user_info(username)
			@url += @endpoints.light_params
			theHash = getHash
			theHash['data']['username']
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
			$tools.checkHTTPResp(clientHTTP("delete"))
		end
		def repostPost(post_id)
			@url = @endpoints.repost(post_id)
			@url += @endpoints.light_params
			httpPost(@url)
		end
		def unrepostPost(post_id)
			@url = @endpoints.repost(post_id)
			@url += @endpoints.light_params
			$tools.checkHTTPResp(clientHTTP("delete"))
		end
		def ifExists(post_id)
			theHash = getHash
			postInfo = theHash['data']
			return postInfo['text'], postInfo['user']['username']
		end
		def getOriginalPost(post_id)
			theHash = getHash
			theHash['data']['repost_of']['id']
		end
		def getUserFollowInfo(username)
			@url = @endpoints.user_info(username)
			@url += @endpoints.light_params
			theHash = getHash
			{you_follow: theHash['data']['you_follow'], follows_you: theHash['data']['follows_you']}
		end
		def getUserMuteInfo(username)
			@url = @endpoints.user_info(username)
			@url += @endpoints.light_params
			theHash = getHash
			theHash['data']['you_muted']
		end
		def muteUser(username)
			@url = @endpoints.mute(username)
			@url += @endpoints.light_params
			httpPost(@url)
		end
		def unmuteUser(username)
			@url = @endpoints.mute(username)
			@url += @endpoints.light_params
			$tools.checkHTTPResp(clientHTTP("delete"))
		end
		def followUser(username)
			@url = @endpoints.follow(username)
			@url += @endpoints.light_params
			httpPost(@url)
		end
		def unfollowUser(username)
			@url = @endpoints.follow(username)
			@url += @endpoints.light_params
			$tools.checkHTTPResp(clientHTTP("delete"))
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
			@url += "&count=200"
			@url += "&before_id=#{beforeID}" if beforeID != nil
			getHash
		end
		def getMuted(username, beforeID)
			@url = @endpoints.muted(username)
			@url += @endpoints.light_params
			@url += "&count=200"
			@url += "&before_id=#{beforeID}" if beforeID != nil
			getHash
		end
		def getSearch(words)
			@url = @endpoints.search(words)
			@url += @endpoints.base_params
			getHash
		end
		def unique_message(channel_id, message_id)
			@url = @endpoints.get_message(channel_id, message_id)
			@url += @endpoints.base_params
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
		def get_pm_channels
			@url = @endpoints.channels
			@url += @endpoints.base_params
			@url += "&channel_types=net.app.core.pm"
			@url += "&include_recent_message=1"
			getHash
		end
		def get_channels
			@url = @endpoints.channels
			@url += @endpoints.base_params
			@url += "&include_recent_message=1"
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
			$tools.checkHTTPResp(clientHTTP("delete"))
		end
		def deleteMessage(channel_id, message_id)
			@url = @endpoints.get_message(channel_id, message_id)
			@url += @endpoints.access_token
			$tools.checkHTTPResp(clientHTTP("delete"))
		end
		# def deactivateChannel(channel_id)
		# 	@url = CHANNELS_URL + "#{channel_id}?"
		# 	@url += @endpoints.access_token
		# 	resp = clientHTTP("delete")
		# 	$tools.checkHTTPResp(resp)
		# end
	end
end