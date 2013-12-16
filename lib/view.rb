#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class View
		def initialize(hash)
			@hash = hash
		end
		def getData(hash)
			adn_data = @hash['data']
			adn_data_reverse = adn_data.reverse
		end
		def getDataNormal(hash)
			adn_data = @hash['data']
		end
		def showMessagesFromChannel
			buildMessages(getData(@hash))
		end
		def showStream
			if $loaded
				if $downsideTimeline == true
					the_hash = getData(@hash)
				else
					the_hash = getDataNormal(@hash)
				end
			else
				the_hash = getData(@hash)
			end
			buildStream(the_hash)
		end
		def showCompleteStream
			if $loaded
				if $downsideTimeline == true
					the_hash = getData(@hash)
				else
					the_hash = getDataNormal(@hash)
				end
			else
				the_hash = getData(@hash)
			end
			stream, pagination_array = buildCompleteStream(the_hash)
		end
		def showChannels
			stream, pagination_array = buildChannelsInfos(@hash)
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
				users += "#{handle}".red + " - " + "#{name}\n".cyan
			end
			hash_length = @hash.length
			return users, hash_length
		end

		def showUsersInfos(name)
			adn_data = @hash['data']
			buildUserInfos(name, adn_data)
		end
		def showPostInfos(post_id, is_mine)
			post_hash = @hash['data']
			buildPostInfo(post_hash, is_mine)
		end
		def buildDebugStream(post_hash)
			ret_string = ""
			post_hash.each do |k, v|
				ret_string += "#{k}: #{v}\n\n"
			end
			return ret_string
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
				inter_string += "-----\n\n".blue
				inter_string += "Date: ".green + "#{created_day} #{created_hour}\n".cyan
				case action
				when "follow", "unfollow"
					inter_string += "#{users_list.join(", ")} ".green + "#{action}ed ".magenta + "you\n".brown
				when "mute", "unmute"
					inter_string += "#{users_list.join(", ")} ".green + "#{action}d ".magenta + "#{objects_names.join(", ")}\n".brown
				when "repost", "unrepost"
					inter_string += "#{users_list.join(", ")} ".green + "#{action}ed:\n".magenta
					inter_string += "#{post_text.join(" ")}"
				when "star", "unstar"
					inter_string += "#{users_list.join(", ")} ".green + "#{action}red:\n".magenta
					inter_string += "#{post_text.join(" ")}"
				when "reply"
					inter_string += "#{users_list.join(", ")} ".green + "#{action}ed to:\n".magenta
					inter_string += "#{post_text.join(" ")}"
				when "welcome"
					inter_string += "App.net ".green + "welcomed ".magenta + "you.\n".green
				else
					inter_string += "Unknown data.\n".red
				end
				inter_string += "\n"
			end
			return inter_string
		end

		def objectDate(item)
			created_at = item['created_at']
			created_day = created_at[0...10]
			created_hour = created_at[11...19]
			return created_day, created_hour
		end
		def objectLinks(links)
			if !links.empty?
				links_string = ""
				links_array = []
				links.each do |link|
					linkURL = link['url']
					links_array.push(linkURL)
				end
				#links_array.reverse.each do |linkURL|
				links_array.each do |linkURL|
					links_string += "Link: ".cyan + linkURL.brown + "\n"
				end
			else
				links_string = ""
			end
			return links_string
		end
		def objectNames(item)
			user_name = item['username']
			user_real_name = item['name']
			user_handle = "@" + user_name
			return user_name, user_real_name, user_handle
		end
		def filesDetails(item)
			file_name = item['name']
			file_token = item['file_token']
			file_source_name = item['source']['name']
			file_source_url = item['source']['link']
			file_kind = item['kind']
			file_id = item['id']
			file_size = item['size']
			file_size_converted = file_size.to_filesize unless file_size == nil
			file_public = item['public']
			return file_name, file_token, file_source_name, file_source_url, file_kind, file_id, file_size, file_size_converted, file_public
		end
		def derivedFilesDetails(derived_files)
			if derived_files != nil
				if derived_files['image_thumb_960r'] != nil
					file_derived_bigthumb_name = derived_files['image_thumb_960r']['name']
					file_derived_bigthumb_url = derived_files['image_thumb_960r']['url']
				end
				if derived_files['image_thumb_200s'] != nil
					file_derived_smallthumb_name = derived_files['image_thumb_200s']['name']
					file_derived_smallthumb_url = derived_files['image_thumb_200s']['url']
				end
				list_string += "\nBig thumbnail: ".cyan + file_derived_bigthumb_url unless file_derived_bigthumb_url == nil
				list_string += "\nSmall thumbnail: ".cyan + file_derived_smallthumb_url unless file_derived_smallthumb_url == nil
			end
			return list_string
		end

		def buildStream(post_hash)
			post_string = ""
			post_hash.each do |item|
				post_text = item['text']
				post_text != nil ? (colored_post = $tools.colorize(post_text)) : (colored_post = "--Post deleted--".red)
				user_name = item['user']['username']
				created_day, created_hour = objectDate(item)
				links = item['entities']['links']
				post_id = item['id']
				post_string += "Post ID: ".cyan + post_id.to_s.green
				post_string += " - "
				post_string += created_day.cyan + ' at ' + created_hour.cyan + ' by ' + "@".green + user_name.green + "\n" + colored_post + "\n"
				links_string = objectLinks(links)
				post_string += links_string + "\n"
			end
			return post_string
		end
		def buildMessages(messages_stream)
			messages_string = ""
			messages_stream.each do |item|
				message_text = item['text']
				message_text != nil ? (colored_post = $tools.colorize(message_text)) : (colored_post = "--Post deleted--".red)
				created_day, created_hour = objectDate(item)
				links = item['entities']['links']
				user_name = item['user']['username']
				post_id = item['id']
				messages_string += "Post ID: ".cyan + post_id.to_s.green
				messages_string += " - "
				messages_string += created_day.cyan + ' ' + created_hour.cyan + " by " + "@".green + user_name.green + "\n" + colored_post + "\n"
				links_string = objectLinks(links)
				messages_string += links_string + "\n"
			end
			last_viewed = messages_stream.last
			last_id = last_viewed['pagination_id'] unless last_viewed == nil
			return messages_string, last_id
		end
		def buildCompleteStream(post_hash)
			post_string = ""
			pagination_array = []
			new_tags = []
			$skipped_tags.each do |tag|
				new_tag = "#" + tag.downcase
				new_tags << new_tag
			end
			post_hash.each do |item|
				pagination_array.push(item['pagination_id'])
				post_text = item['text']
				post_id = item['id']
				source_name = item['source']['name']
				source_link = item['source']['link']
				#Skip sources
				case source_name
				when *$skipped_sources
					# post_string += "Post ID: ".cyan + post_id.to_s.green
					# post_string += " -" + " SKIPPED".cyan
					# matched = $skipped_sources.index(source_name)
					# post_string += " \"#{$skipped_sources[matched]}\"\n\n".cyan
					next
				end
				#Skip hashtags
				skipped_hashtags_encountered = false
				post_text != nil ? splitted = post_text.split(" ") : next
				splitted.each do |word|
					word.downcase
					case word
					when *new_tags
						skipped_hashtags_encountered = true
						next
					end
				end
				next if skipped_hashtags_encountered
				entitiesMentions = item['entities']['mentions']
				postMentionsArray = []
				entitiesMentions.each do |item|
					postMentionsArray.push(item['name'])
				end
				post_text != nil ? (colored_post = $tools.colorize(post_text)) : (colored_post = "--Post deleted--".red)
				user_name, user_real_name, handle = objectNames(item['user'])
				created_day, created_hour = objectDate(item)
				post_date = created_day.cyan + " " + created_hour.cyan
				#post_string += "Post ID: ".cyan + post_id.to_s.green
				#post_string += " - "
				#post_string += created_day.cyan + ' at ' + created_hour.cyan + ' by ' + "@".reddish + user_name.reddish + "\n" + colored_post + "\n"
				#post_string += post_id.to_s.green + " " + created_day.cyan + " " + created_hour.cyan + " " + "[#{user_real_name}]".blue + " " + "@".reddish + user_name.reddish + "\n" + colored_post + "\n"
				#post_string += post_id.to_s.green.ljust(14) + " " + handle.reddish + " [#{user_real_name}]".magenta + " " + post_date + " "
				me_mentioned = false
				postMentionsArray.each do |name|
					if name == $identityPrefix
						me_mentioned = true
					end
				end
				if me_mentioned == true
					post_string += post_id.to_s.cyan.reverse_color.ljust(14) + " " + handle.green + " [#{user_real_name}]".magenta + " " + post_date + " "
				else
					post_string += post_id.to_s.cyan.ljust(14) + " " + handle.green + " [#{user_real_name}]".magenta + " " + post_date + " "
				end
				#post_string += "[#{source_name}]".blue if $configShowClient == true
				post_string += "[#{source_name}]".cyan if $configShowClient == true
				post_string += "\n" + colored_post + "\n"
				links = item['entities']['links']
				annotations_list = item['annotations']
				xxx = 0
				if annotations_list != nil
					annotations_list.each do |it|
						annotation_type = annotations_list[xxx]['type']
						annotation_value = annotations_list[xxx]['value']
						if annotation_type == "net.app.core.checkin" or annotation_type == "net.app.ohai.location"
							checkins_name = annotation_value['name']
							checkins_address = annotation_value['address']
							checkins_locality = annotation_value['locality']
							checkins_region = annotation_value['region']
							checkins_postcode = annotation_value['postcode']
							checkins_country_code = annotation_value['country_code']
							fancy = checkins_name.length + 7
							post_string += "." * fancy #longueur du nom plus son étiquette
							unless checkins_name.nil?
								post_string += "\nName: ".cyan + checkins_name.upcase.reddish
							end
							unless checkins_address.nil?
								post_string += "\nAddress: ".cyan + checkins_address.green
							end
							unless checkins_locality.nil?
								post_string += "\nLocality: ".cyan + checkins_locality.green
							end
							unless checkins_postcode.nil?
								post_string += " (#{checkins_postcode})".green
							end
							unless checkins_region.nil?
								post_string += "\nState/Region: ".cyan + checkins_region.green
							end
							unless checkins_country_code.nil?
								post_string += " (#{checkins_country_code})".upcase.green
							end
							unless source_name.nil?
								post_string += "\nPosted with: ".cyan + "#{source_name} [#{source_link}]".green + " "
							end
							post_string += "\n"
						end
						xxx += 1
					end
				end
				links_string = objectLinks(links)
				post_string += links_string + "\n\n"
			end
			return post_string, pagination_array
		end
		def buildSimplePost(post_hash)
			post_text = post_hash['text']
			post_text != nil ? (colored_post = $tools.colorize(post_text)) : (colored_post = "--Post deleted--".red)
			user_name = post_hash['user']['username']
			created_day, created_hour = objectDate(post_hash)
			post_id = post_hash['id']
			post_string = "Post ID: ".cyan + post_id.to_s.red.reverse_color
			post_string += " - "
			post_string += created_day.cyan + ' at ' + created_hour.cyan + ' by ' + "@".reddish + user_name.reddish + "\n" + colored_post + "\n"
			links = post_hash['entities']['links']
			source_name = post_hash['source']['name']
			source_link = post_hash['source']['link']
			links_string = objectLinks(links)
			post_string += links_string + "\n"
		end
		def buildSimplePostView(post_hash)
			the_post_id = post_hash['id']
			post_text = post_hash['text']
			user_name, user_real_name, the_name = objectNames(post_hash['user'])
			post_text != nil ? (colored_post = $tools.colorize(post_text)) : (colored_post = "--Post deleted--".red)
			created_day, created_hour = objectDate(post_hash)
			post_details = created_day.cyan + " " + the_post_id.green + " " + the_name.brown
			if !user_real_name.empty?
				post_details += " #{user_real_name}".pink
			end
			post_details += "\n" + colored_post + "\n\n"
		end

		def buildSimplePostInfo(post_hash)
			the_post_id = post_hash['id']
			post_text = post_hash['text']
			post_URL = post_hash['canonical_url']
			post_details = "Post URL: ".cyan + post_URL.brown + "\n"
			is_reply = post_hash['reply_to']
			if is_reply != nil
				post_details += "This post is a reply to post ".cyan + is_reply.brown + "\n"
			end
			if post_text != nil
				to_regex = post_text.dup
				without_Markdown = $tools.getMarkdownText(to_regex)
				without_braces = $tools.withoutSquareBraces(without_Markdown)
				actual_length = without_braces.length
				post_details += "\nLength: ".cyan + actual_length.to_s.reddish
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
			links = post_hash['entities']['links']
			post_details = "\nThe " + created_day.cyan + ' at ' + created_hour.cyan + ' by ' + "@".green + user_name.green
			if !user_real_name.empty?
				post_details += " \[#{user_real_name}\]".reddish
			end
			post_details += ":\n"
			post_details += "\n" + colored_post + "\n\n" 
			post_details += "Post ID: ".cyan + the_post_id.to_s.green + "\n"
			links_string = objectLinks(links)
			post_details += links_string + "\n"
			post_URL = post_hash['canonical_url']
			post_details += "\nPost URL: ".cyan + post_URL.brown
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
				post_details += "\nThis post is a reply to post ".cyan + is_reply.brown
			end
			if is_mine == false
				if repost_of != nil
					repost_id = repost_of['id']
					post_details += "\nThis post is a repost of post ".cyan + repost_id.brown
				else
					post_details += "\nReplies: ".cyan + num_replies.to_s.reddish
					post_details += "  Reposts: ".cyan + num_reposts.to_s.reddish
					post_details += "  Stars: ".cyan + num_stars.to_s.reddish
				end
				if you_reposted == true
					post_details += "\nYou reposted this post.".cyan
				end
				if you_starred == true
					post_details += "\nYou starred this post.".cyan
				end
				post_details += "\nPosted with: ".cyan + source_app.reddish
				post_details += "  Locale: ".cyan + locale.reddish
				post_details += "  Timezone: ".cyan + timezone.reddish
			else
				to_regex = post_text.dup
				without_Markdown = $tools.getMarkdownText(to_regex)
				without_braces = $tools.withoutSquareBraces(without_Markdown)
				actual_length = without_braces.length
				post_details += "\nLength: ".cyan + actual_length.to_s.reddish
			end
			post_details += "\n\n\n"
		end
		def buildUsersList(users_hash)
			users_string = ""
			users_hash.each do |item|
				user_name, user_real_name, user_handle = objectNames(item)
				users_string += user_handle.green + " #{user_real_name}\n".cyan
			end
			users_string += "\n\n"
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
			list_string += "\nName: ".cyan + file_name.green
			list_string += "\nKind: ".cyan + file_kind.pink
			list_string += "\nSize: ".cyan + file_size_converted.reddish unless file_size == nil
			list_string += "\nDate: ".cyan + created_day.green + " " + created_hour.green
			list_string += "\nSource: ".cyan + file_source_name.brown + " - #{file_source_url}".brown
			if file_public == true
				list_string += "\nThis file is ".cyan + "public".blue
				file_url = resp_hash['url_permanent']
			else
				list_string += "\nThis file is ".cyan + "private".red
				file_url = resp_hash['url']
			end
			if with_url == true
				list_string += "\nURL: ".cyan + file_url
				#list_string += derivedFilesDetails(derived_files)
			end
			list_string += "\n\n"
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
				list_string += "\nID: ".cyan + file_id.brown
				list_string += "\nName: ".cyan + file_name.green
				list_string += "\nKind: ".cyan + file_kind.pink
				list_string += " Size: ".cyan + file_size_converted.reddish unless file_size == nil
				list_string += "\nDate: ".cyan + created_day.green + " " + created_hour.green
				list_string += "\nSource: ".cyan + file_source_name.brown + " - #{file_source_url}".brown
				if file_public == true
					list_string += "\nThis file is ".cyan + "public".blue
					list_string += "\nLink: ".cyan + item['url_short'].magenta
				else
					list_string += "\nThis file is ".cyan + "private".red
					if with_url == true
						file_url = item['url']
						list_string += "\nURL: ".cyan + file_url.brown
						#list_string += derivedFilesDetails(derived_files)
					end
				end
				list_string += "\n"
			end
			list_string += "\n"
			return list_string, file_url, pagination_array
		end
		def buildChannelsInfos(hash)
			meta = hash['meta']
			unread_messages = meta['unread_counts']['net.app.core.pm']
			data = hash['data']
			the_channels = ""
			channels_list = []
			puts "Getting users infos, please wait a few seconds... (could take a while if many channels)\n".cyan
			data.each do |item|
				channel_id = item['id']
				channel_type = item['type']
				if channel_type == "net.app.core.pm"
					channels_list.push(channel_id)
					total_messages = item['counts']['messages']
					owner = "@" + item['owner']['username']
					writers = item['writers']['user_ids']
					readers = item['readers']['user_ids']
					you_write = item['writers']['you']
					you_read = item['readers']['you']
					the_writers, the_readers = [], []
					writers.each do |writer|
						if writer != nil
							user = AyaDN::API.new(@token).getUserInfos(writer)
							name = user['data']['username']
							the_writers.push("@" + name)
							#the_writers.push(writer) 
						end
					end
					the_channels += "\nChannel ID: ".cyan + "#{channel_id}\n".brown
					the_channels += "Creator: ".cyan + owner.magenta + "\n"
					#the_channels += "Channels type: ".cyan + "#{channel_type}\n".brown
					the_channels += "Interlocutor(s): ".cyan + the_writers.join(", ").magenta + "\n"
				end
				if channel_type == "com.ayadn.drafts"
					$drafts = channel_id
					channels_list.push(channel_id)
					the_channels += "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "your AyaDN Drafts channel\n".green
				end
			end
			the_channels += "\n"
			return the_channels, channels_list
		end
		def buildUserInfos(name, adn_data)
			user_name, user_real_name, the_name = objectNames(adn_data)
			user_id = adn_data['id']
			user_show = ""			
			user_show += "ID: ".cyan.ljust(21) + user_id.green + "\n"
			if user_real_name != nil
				user_show += "Name: ".cyan.ljust(21) + user_real_name.green + "\n"
			end
			if adn_data['description'] != nil
				user_descr = adn_data['description']['text']
			else
				user_descr = "No description available.".cyan
			end
			user_timezone = adn_data['timezone']
			if user_timezone != nil
				user_show += "Timezone: ".cyan.ljust(21) + user_timezone.green + "\n"
			end
			locale = adn_data['locale']
			if locale != nil
				user_show += "Locale: ".cyan.ljust(21) + locale.green + "\n"
			end
			user_posts = adn_data['counts']['posts']
			user_followers = adn_data['counts']['followers']
			user_following = adn_data['counts']['following']
			user_show += "Posts: ".cyan.ljust(21) + user_posts.to_s.green + "\n" + "Followers: ".cyan.ljust(21) + user_followers.to_s.green + "\n" + "Following: ".cyan.ljust(21) + user_following.to_s.green + "\n"
			user_show += "Web: ".cyan.ljust(21) + "http://".green + adn_data['verified_domain'].green + "\n" if adn_data['verified_domain'] != nil
			user_show += "\n"
			user_show += the_name.brown
			if name != "me"
				user_follows = adn_data['follows_you']
				user_followed = adn_data['you_follow']
				user_is_muted = adn_data['you_muted']
				if user_follows == true
					user_show += " follows you\n".green
				else
					user_show += " doesn't follow you\n".reddish
				end
				if user_followed == true
					user_show += "You follow ".green + the_name.brown + "\n"
				else
					user_show += "You don't follow ".reddish + the_name.brown + "\n"
				end
				if user_is_muted == true
					user_show += "You muted ".reddish + the_name.brown + "\n"
				end
			else
				user_show += ":".cyan + " yourself!".brown + "\n"
			end
			user_show += "\n"
			user_show += "Bio: \n\n".cyan + user_descr + "\n\n"
		end
	end
end