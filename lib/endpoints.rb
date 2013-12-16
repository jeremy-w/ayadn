#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN

	AYADN_CLIENT_ID = "hFsCGArAjgJkYBHTHbZnUvzTmL4vaLHL"
	AYADN_CALLBACK_URL = "http://aya.io/ayadn/auth.html"

	BASE_URL = "https://alpha-api.app.net/"
	POSTS_URL = BASE_URL + "stream/0/posts/"
	USERS_URL = BASE_URL + "stream/0/users/"
	FILES_URL = BASE_URL + "stream/0/files/"
	CHANNELS_URL = BASE_URL + "stream/0/channels/"
	PM_URL = CHANNELS_URL + "pm/messages"

	class Endpoints
		def initialize(token)
			@token = token
		end
		def authorize_url
			"https://account.app.net/oauth/authenticate?client_id=#{AYADN_CLIENT_ID}&response_type=token&redirect_uri=#{AYADN_CALLBACK_URL}&scope=basic stream write_post follow public_messages messages files&include_marker=1"
		end
		def global
			POSTS_URL + "stream/global?access_token=#{@token}&count=#{$countGlobal}"
		end
		def unified
			POSTS_URL + "stream/unified?access_token=#{@token}&count=#{$countUnified}"
		end
		def unified_streamback
			POSTS_URL + "stream/unified?access_token=#{@token}&count=#{$countStreamback}"
		end
		def single_post(post_id)
			POSTS_URL + "#{post_id}?access_token=#{@token}"
		end
		# def checkins
		# 	POSTS_URL + "stream/explore/checkins?access_token=#{@token}&count=#{$countCheckins}"
		# end
		# def trending
		# 	POSTS_URL + "stream/explore/trending?access_token=#{@token}&count=#{$countExplore}"
		# end
		# def conversations
		# 	POSTS_URL + "stream/explore/conversations?access_token=#{@token}"
		# end
		def explore(stream)
			case stream
			when "checkins"
				POSTS_URL + "stream/explore/checkins?access_token=#{@token}&count=#{$countCheckins}"
			when "trending", "conversations", "photos"
				POSTS_URL + "stream/explore/#{stream}?access_token=#{@token}&count=#{$countExplore}"
			end
		end
		# def photos
		# 	POSTS_URL + "stream/explore/photos?access_token=#{@token}&count=#{$countExplore}"
		# end
		def hashtags(tags)
			POSTS_URL + "tag/#{tags}"
		end
		def who_reposted(post_id)
			POSTS_URL + "#{post_id}/reposters/?access_token=#{@token}"
		end
		def who_starred(post_id)
			POSTS_URL + "#{post_id}/stars/?access_token=#{@token}"
		end
		def replies(post_id)
			POSTS_URL + "#{post_id}/replies/?access_token=#{@token}"
		end
		def star(post_id)
			POSTS_URL + "#{post_id}/star/?access_token=#{@token}"
		end
		def repost(post_id)
			POSTS_URL + "#{post_id}/repost/?access_token=#{@token}"
		end
		def search(words)
			POSTS_URL + "search?text=#{words}?access_token=#{@token}"
		end
		def mentions(username)
			USERS_URL + "#{username}/mentions/?access_token=#{@token}&count=#{$countMentions}"
		end
		def posts(username)
			USERS_URL + "#{username}/posts/?access_token=#{@token}&count=#{$countPosts}"
		end
		def user_info(username)
			USERS_URL + "#{username}/?access_token=#{@token}"
		end
		def starred_posts(username)
			USERS_URL + "#{username}/stars/?access_token=#{@token}&count=#{$countStarred}"
		end
		def follow(username)
			USERS_URL + "#{username}/follow/?access_token=#{@token}"
		end
		def following(username)
			USERS_URL + "#{username}/following/?access_token=#{@token}"
		end
		def followers(username)
			USERS_URL + "#{username}/followers/?access_token=#{@token}"
		end
		def mute(username)
			USERS_URL + "#{username}/mute/?access_token=#{@token}"
		end
		def muted(username)
			USERS_URL + "#{username}/muted/?access_token=#{@token}"
		end
		def interactions
			USERS_URL + "me/interactions?access_token=#{@token}"
		end
		def channels
			CHANNELS_URL + "?access_token=#{@token}"
		end
		def messages(channel_id)
			CHANNELS_URL + "#{channel_id}/messages?access_token=#{@token}"
		end
		def get_message(channel_id, message_id)
			CHANNELS_URL + "#{channel_id}/messages/#{message_id}?access_token=#{@token}"
		end
		def files_list
			USERS_URL + "me/files?access_token=#{@token}"
		end
		def get_file(file_id)
			FILES_URL + "#{file_id}?access_token=#{@token}"
		end
		def get_multiple_files(file_ids)
			FILES_URL + "?ids=#{file_ids}&access_token=#{@token}"
		end
		def access_token
			"access_token=#{@token}"
		end
		def include_deleted
			"&include_deleted=1"
		end
		def exclude_deleted
			"&include_deleted=0"
		end
		def include_html
			"&include_html=1"
		end
		def exclude_html
			"&include_html=0"
		end
		def include_directed
			"&include_directed_posts=1"
		end
		def exclude_directed
			"&include_directed_posts=0"
		end
		def include_annotations
			"&include_annotations=1"
		end
		def exclude_annotations
			"&include_annotations=0"
		end
		def base_params
			"&include_html=0&include_annotations=1&include_deleted=1"
		end
		def light_params
			"&include_html=0&include_annotations=0&include_deleted=0"
		end
	end
end