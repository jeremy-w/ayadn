#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class View
		def initialize(hash)
			@hash = hash
		end
		def getData(hash)
			adn_data = hash['data']
			adn_data_reverse = adn_data.reverse
		end
		def getDataNormal(hash)
			adn_data = hash['data']
		end
		def showMessagesFromChannel
			buildMessages(getData(@hash))
		end
		def showStream
			$downsideTimeline ? the_hash = getData(@hash) : the_hash = getDataNormal(@hash)
			buildStream(the_hash)
		end
		def showCompleteStream
			$downsideTimeline ? the_hash = getData(@hash) : the_hash = getDataNormal(@hash)
			stream, pagination_array = buildCompleteStream(the_hash)
		end
		def showChannels(type)
			stream, pagination_array = buildChannelsInfos(@hash, type)
		end
		def showDebugStream
			buildDebugStream(getDataNormal(@hash))
		end

		def showUsersList
			buildUsersList(getDataNormal(@hash))
		end
		def showInteractions
			buildInteractions(getData(@hash))
		end

		def showUsers
			users = ""
			sorted_hash = @hash.sort
			sorted_hash.each do |handle, name|
				users << "#{handle}".red + " - " + "#{name}\n".cyan
			end
			hash_length = @hash.length
			return users, hash_length
		end

		def showUsersInfos(name)
			buildUserInfos(name, getDataNormal(@hash))
		end
		def showPostInfos(post_id, is_mine)
			buildPostInfo(getDataNormal(@hash), is_mine)
		end
		def buildDebugStream(post_hash)
			# ret_string = ""
			# post_hash.each do |k, v|
			# 	ret_string << "#{k}: #{v}\n\n"
			# end
			jj post_hash
			#exit
			#return ret_string
		end

		def buildInteractions(hash)
			inter_string = ""
			hash.each do |item|
				action = item['action']
				created_day = item['event_date'][0...10]
				created_hour = item['event_date'][11...19]
				objects_names, users_list, post_ids, post_text = [], [], [], [] # not the same as var1 = var2 = []
				objects = item['objects']
				obj_has_names = false
				objects.each do |o|
					case action
					when "follow", "unfollow", "mute", "unmute"
						object_user_names = "@" + o['username']
						objects_names.push(object_user_names)
					when "star", "unstar", "repost", "unrepost", "reply"
						post_id = o['id']
						post_ids.push(post_id)
						text = o['text']
						post_info = buildPostInfo(o, false)
						post_text.push(post_info.chomp("\n\n"))
						#post_text << text
					end
				end
				users = item['users']
				users.each do |u|
					if u != nil
						user_name = "@" + u['username']
						users_list.push(user_name)
					end
				end
				joined_users_list = users_list.join(", ")
				joined_post_text = post_text.join(" ")
				inter_string << "-----\n\n".blue
				inter_string << "Date: ".green + "#{created_day} #{created_hour}\n".cyan
				case action
				when "follow", "unfollow"
					inter_string << "#{joined_users_list} ".green + "#{action}ed ".magenta + "you\n".brown
				when "mute", "unmute"
					inter_string << "#{joined_users_list} ".green + "#{action}d ".magenta + "#{objects_names.join(", ")}\n".brown
				when "repost", "unrepost"
					inter_string << "#{joined_users_list} ".green + "#{action}ed:\n".magenta
					inter_string << joined_post_text
				when "star", "unstar"
					inter_string << "#{joined_users_list} ".green + "#{action}red:\n".magenta
					inter_string << joined_post_text
				when "reply"
					inter_string << "#{joined_users_list} ".green + "#{action}ed to:\n".magenta
					inter_string << joined_post_text
				when "welcome"
					inter_string << "App.net ".green + "welcomed ".magenta + "you.\n".green
				else
					inter_string << "Unknown data.\n".red
				end
				inter_string << "\n"
			end
			return inter_string
		end

		def create_content_string(item, annotations, me_mentioned)
			post_id = item['id']
			num_replies = item['num_replies']
			reply_to = item['reply_to']
			user_name, user_real_name, user_handle = objectNames(item['user'])
			created_day, created_hour = objectDate(item)
			links_string = objectLinks(item)
			colored_post = coloredText(item)
			post_string = objectView(post_id, created_day, created_hour, user_handle, user_real_name, colored_post, links_string, annotations, me_mentioned, num_replies, reply_to)
		end

		def skip_hashtags(item, saved_tags)
			entities_tags = item['entities']['hashtags']
			skipped_hashtags_encountered = false
			for post_tag in entities_tags do
				case post_tag['name']
				when *saved_tags
					skipped_hashtags_encountered = true
			 		next # get out of this loop
				end
			end
			return skipped_hashtags_encountered
		end

		def buildStream(post_hash)
			post_string = ""
			for item in post_hash do
				# create_content_string(item, annotations, me_mentioned)
				post_string << create_content_string(item, nil, false)
			end
			return post_string
		end
		def buildMessages(messages_stream)
			messages_string = ""
			for item in messages_stream do
				@source_name, @source_link = objectSource(item)
				annotations = checkins_annotations(item)
				messages_string << create_content_string(item, annotations, false) # create_content_string(item, annotations, me_mentioned)
			end
			last_viewed = messages_stream.last
			last_id = last_viewed['pagination_id'] unless last_viewed == nil
			return messages_string, last_id
		end

		def buildCompleteStream(post_hash)
			post_string = ""
			pagination_array = []
			saved_tags = []
			if $skipped_tags != nil
				for tag in $skipped_tags do
					saved_tags << tag.downcase
				end
			end
			#post_hash.each do |item|
			for item in post_hash do
				pagination_array.push(item['pagination_id'])
				next if item['text'] == nil
				@source_name, @source_link = objectSource(item)
				case @source_name
				when *$skipped_sources
					next
				end
				next if skip_hashtags(item, saved_tags)
				entitiesMentions = item['entities']['mentions']
				postMentionsArray = []
				@skipped_mentions_encountered = false
				for mention in entitiesMentions do
					case mention['name']
					when *$skipped_mentions
						@skipped_mentions_encountered = true
						next
					end
					postMentionsArray.push(mention['name'])
				end
				next if @skipped_mentions_encountered == true
				me_mentioned = false
				for name in postMentionsArray do
					me_mentioned = true if name == $identityPrefix
				end
				colored_post = coloredText(item)
				user_name, user_real_name, handle = objectNames(item['user'])
				created_day, created_hour = objectDate(item)
				annotations = checkins_annotations(item)
				post_string << create_content_string(item, annotations, me_mentioned)
			end
			return post_string, pagination_array
		end
		def buildSimplePost(post_hash)
			colored_post = coloredText(post_hash)
			user_name, user_real_name, handle = objectNames(post_hash['user'])
			created_day, created_hour = objectDate(post_hash)
			post_string = create_content_string(post_hash, nil, false)
		end
		def buildSimplePostInfo(post_hash)
			the_post_id = post_hash['id']
			post_text = post_hash['text']
			post_URL = post_hash['canonical_url']
			post_details = "Post URL: ".cyan + post_URL.brown + "\n"
			is_reply = post_hash['reply_to']
			if is_reply != nil
				post_details << "This post is a reply to post ".cyan + is_reply.brown + "\n"
			end
			if post_text != nil
				to_regex = post_text.dup
				without_Markdown = $tools.getMarkdownText(to_regex)
				without_braces = $tools.withoutSquareBraces(without_Markdown)
				actual_length = without_braces.length
				post_details << "\nLength: ".cyan + actual_length.to_s.reddish
			end
			return post_details + "\n\n"
		end
		def buildPostInfo(post_hash, is_mine)
			post_text = post_hash['text']
			post_text != nil ? (colored_post = $tools.colorize(post_text)) : (puts "--Post deleted--\n\n".red; exit)
			the_post_id = post_hash['id']
			user_name, user_real_name, the_name = objectNames(post_hash['user'])
			user_follows = post_hash['follows_you']
			user_followed = post_hash['you_follow']
			created_day, created_hour = objectDate(post_hash)
			post_details = "\nThe " + created_day.cyan + ' at ' + created_hour.cyan + ' by ' + the_name.green
			if !user_real_name.empty?
				post_details << " [#{user_real_name}]".reddish
			end
			post_details << ":\n"
			post_details << "\n" + colored_post + "\n\n" 
			post_details << "Post ID: ".cyan + the_post_id.to_s.green + "\n"
			links_string = objectLinks(post_hash)
			post_details << links_string + "\n"
			post_URL = post_hash['canonical_url']
			post_details << "\nPost URL: ".cyan + post_URL.brown
			num_stars = post_hash['num_stars']
			num_replies = post_hash['num_replies']
			num_reposts = post_hash['num_reposts']
			you_reposted = post_hash['you_reposted']
			you_starred = post_hash['you_starred']
			source_app = post_hash['source']['name']
			locale = post_hash['user']['locale']
			timezone = post_hash['user']['timezone']
			is_reply = post_hash['reply_to']
			repost_of = post_hash['repost_of']
			if is_reply != nil
				post_details << "\nThis post is a reply to post ".cyan + is_reply.brown
			end
			if is_mine == false
				if repost_of != nil
					repost_id = repost_of['id']
					post_details << "\nThis post is a repost of post ".cyan + repost_id.brown
				else
					post_details << "\nReplies: ".cyan + num_replies.to_s.reddish
					post_details << "  Reposts: ".cyan + num_reposts.to_s.reddish
					post_details << "  Stars: ".cyan + num_stars.to_s.reddish
				end
				if you_reposted == true
					post_details << "\nYou reposted this post.".cyan
				end
				if you_starred == true
					post_details << "\nYou starred this post.".cyan
				end
				post_details << "\nPosted with: ".cyan + source_app.reddish
				post_details << "  Locale: ".cyan + locale.reddish
				post_details << "  Timezone: ".cyan + timezone.reddish
			else
				without_braces = $tools.withoutSquareBraces($tools.getMarkdownText(post_text.dup))
				post_details << "\nLength: ".cyan + without_braces.length.to_s.reddish
			end
			post_details << "\n\n\n"
		end
		def buildUsersList(users_hash)
			users_string = ""
			users_hash.each do |item|
				user_name, user_real_name, user_handle = objectNames(item)
				users_string << user_handle.green + " #{user_real_name}\n".cyan
			end
			users_string << "\n\n"
		end
		def buildFollowList
			#hashes = getDataNormal(@hash)
			hashes = @hash['data']
			meta = @hash['meta']
			#pagination_array = []
			users_hash = {}
			hashes.each do |item|
				user_name, user_real_name, user_handle = objectNames(item)
				#pagination_array.push(item['pagination_id'])
				users_hash[user_handle] = user_real_name
			end
			#return users_hash, pagination_array
			return users_hash, meta['min_id']
		end
		def showFileInfo(with_url)
			resp_hash = getDataNormal(@hash)
			buildFileInfo(resp_hash, with_url)
		end
		def buildFileInfo(resp_hash, with_url)
			created_day, created_hour = objectDate(resp_hash)
			list_string = ""
			file_url = nil
			file_name, file_token, file_source_name, file_source_url, file_kind, file_id, file_size, file_size_converted, file_public = filesDetails(resp_hash)
			file_url_expires = resp_hash['url_expires']
			derived_files = resp_hash['derived_files']
			# list_string += "\nID: ".cyan + file_id.brown
			list_string = file_view(file_name, file_kind, file_size, file_size_converted, file_source_name, file_source_url, created_day, created_hour)
			if file_public == true
				list_string << "\nThis file is ".cyan + "public".blue
				file_url = resp_hash['url_permanent']
			else
				list_string << "\nThis file is ".cyan + "private".red
				file_url = resp_hash['url']
			end
			if with_url == true
				list_string << "\nURL: ".cyan + file_url
				#list_string << derivedFilesDetails(derived_files)
			end
			list_string << "\n\n"
			return list_string, file_url, file_name
		end
		def showFilesList(with_url, reverse)
			if reverse == false
				resp_hash = getData(@hash)
			else
				resp_hash = getDataNormal(@hash)
			end
			list_string = ""
			file_url = nil
			pagination_array = []
			resp_hash.each do |item|
				created_day, created_hour = objectDate(item)
				pagination_array.push(item['pagination_id'])
				file_name, file_token, file_source_name, file_source_url, file_kind, file_id, file_size, file_size_converted, file_public = filesDetails(item)
				file_url_expires = item['url_expires']
				derived_files = item['derived_files']
				list_string << "\nID: ".cyan + file_id.brown
				list_string << file_view(file_name, file_kind, file_size, file_size_converted, file_source_name, file_source_url, created_day, created_hour)
				if file_public == true
					list_string << "\nThis file is ".cyan + "public".blue
					list_string << "\nLink: ".cyan + item['url_short'].magenta
				else
					list_string << "\nThis file is ".cyan + "private".red
					if with_url == true
						file_url = item['url']
						list_string << "\nURL: ".cyan + file_url.brown
						#list_string << derivedFilesDetails(derived_files)
					end
				end
				list_string << "\n"
			end
			list_string << "\n"
			return list_string, file_url, pagination_array
		end
		def buildChannelsInfos(hash, type)
			if type == "net.app.core.pm"
				meta = hash['meta']
				unread_messages = meta['unread_counts']['net.app.core.pm']
				data = hash['data']
				the_channels = ""
				channels_list = []
				puts "\nGetting users infos, please wait a few seconds... (could take a while the first time if you have a lot of channels activated)\n".cyan
				data.each do |item|
					channel_id = item['id']
					channel_type = item['type']
					if channel_type == "net.app.core.pm"
						channels_list.push(channel_id)
						total_messages = item['counts']['messages']
						#owner = "@" + item['owner']['username']
						writers = item['writers']['user_ids']
						readers = item['readers']['user_ids']
						you_write = item['writers']['you']
						you_read = item['readers']['you']
						the_writers, the_readers = [], []
						writers.each do |writer|
							if writer != nil
								user = AyaDN::API.new(@token).getUserInfos(writer)
								name = user['data']['username']
								handle = "@" + name
								$tools.fileOps("savechannelid", channel_id, handle)
								the_writers.push(handle)
							end
						end
						the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown
						#the_channels << "Creator: ".cyan + owner.magenta + "\n"
						#the_channels << "Channels type: ".cyan + "#{channel_type}\n".brown
						the_channels << "Interlocutor(s): ".cyan + the_writers.join(", ").magenta + "\n"
					end
				end
				the_channels << "\n"
				return the_channels, channels_list
			# elsif channel_type == "com.ayadn.drafts"
			# 	$drafts = channel_id
			# 	channels_list.push(channel_id)
			# 	the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "your AyaDN Drafts channel\n".green
			else
				data = hash['data']
				the_channels = ""
				channels_list = []
				data.each do |item|
					channel_id = item['id']
					channel_type = item['type']
					if channel_type != "net.app.core.pm"
						channels_list.push(channel_id)
						if channel_type == "net.app.ohai.journal"
							$tools.fileOps("savechannelid", channel_id, "Ohai Journal")
							the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "your Ohai Journal channel\n".green
						elsif channel_type == "net.paste-app.clips"
							$tools.fileOps("savechannelid", channel_id, "Paste-App Clips")
							the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "your Paste-App Clips channel\n".green
						elsif channel_type == "net.app.core.broadcast"
							broadcast_annotations = item['annotations']
							broadcast_annotations.each do |anno|
								if anno['type'] == "net.app.core.broadcast.metadata"
									broadcast_name = anno['value']['title']
									$tools.fileOps("savechannelid", channel_id, "Broadcast: #{broadcast_name}")
									the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "Broadcast channel: #{broadcast_name}\n".green
								end
							end
						elsif channel_type == "net.patter-app.room"
							patter_room_annotations = item['annotations']
							patter_room_annotations.each do |anno|
								if anno['type'] == "net.patter-app.settings"
									patter_room_name = anno['value']['name']
									$tools.fileOps("savechannelid", channel_id, "Patter-App Room: #{patter_room_name}")
									the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "Patter-App Room: #{patter_room_name}\n".green
									next
								end
							end
						else
							$tools.fileOps("savechannelid", channel_id, channel_type)
							the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "#{channel_type}\n"
						end
					end
				end
				the_channels << "\n"
				return the_channels, channels_list
			end
		end
		def buildUserInfos(name, adn_data)
			user_name, user_real_name, the_name = objectNames(adn_data)
			user_id = adn_data['id']
			user_show = ""			
			user_show << "ID: ".cyan.ljust(21) + user_id.green + "\n"
			if user_real_name != nil
				user_show << "Name: ".cyan.ljust(21) + user_real_name.green + "\n"
			end
			if adn_data['description'] != nil
				user_descr = adn_data['description']['text']
			else
				user_descr = "No description available.".cyan
			end
			user_timezone = adn_data['timezone']
			if user_timezone != nil
				user_show << "Timezone: ".cyan.ljust(21) + user_timezone.green + "\n"
			end
			locale = adn_data['locale']
			if locale != nil
				user_show << "Locale: ".cyan.ljust(21) + locale.green + "\n"
			end
			user_posts = adn_data['counts']['posts']
			user_followers = adn_data['counts']['followers']
			user_following = adn_data['counts']['following']
			user_show << "Posts: ".cyan.ljust(21) + user_posts.to_s.green + "\n" + "Followers: ".cyan.ljust(21) + user_followers.to_s.green + "\n" + "Following: ".cyan.ljust(21) + user_following.to_s.green + "\n"
			user_show << "Web: ".cyan.ljust(21) + "http://".green + adn_data['verified_domain'].green + "\n" if adn_data['verified_domain'] != nil
			user_show << "\n"
			user_show << the_name.brown
			if name != "me"
				user_follows = adn_data['follows_you']
				user_followed = adn_data['you_follow']
				user_is_muted = adn_data['you_muted']
				if user_follows == true
					user_show << " follows you\n".green
				else
					user_show << " doesn't follow you\n".reddish
				end
				if user_followed == true
					user_show << "You follow ".green + the_name.brown + "\n"
				else
					user_show << "You don't follow ".reddish + the_name.brown + "\n"
				end
				if user_is_muted == true
					user_show << "You muted ".reddish + the_name.brown + "\n"
				end
			else
				user_show << ":".cyan + " yourself!".brown + "\n"
			end
			user_show << "\n"
			user_show << "Bio: \n\n".cyan + user_descr + "\n\n"
		end
	end
end