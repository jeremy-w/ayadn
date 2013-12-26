#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class View
		def initialize(hash)
			@hash = hash
		end
		def getData(hash)
			hash['data'].reverse
		end
		def getDataNormal(hash)
			hash['data']
		end
		def showMessagesFromChannel
			buildMessages(getData(@hash))
		end
		def showStream
			$tools.config['timeline']['downside'] ? the_hash = getData(@hash) : the_hash = getDataNormal(@hash)
			buildStream(the_hash)
		end
		def showCompleteStream
			$tools.config['timeline']['downside'] ? the_hash = getData(@hash) : the_hash = getDataNormal(@hash)
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
			@hash.sort.each do |handle, name|
				users << "#{handle}".red + " - " + "#{name}\n".cyan
			end
			return users, @hash.length
		end
		def showUsersInfos(name)
			buildUserInfos(name, getDataNormal(@hash))
		end
		def showPostInfos(post_id, is_mine)
			buildPostInfo(getDataNormal(@hash), is_mine)
		end
		def showFileInfo(with_url)
			buildFileInfo(getDataNormal(@hash), with_url)
		end
		def buildStream(post_hash)
			post_string = "\n"
			for item in post_hash do
				# create_content_string(item, annotations, me_mentioned)
				post_string << create_content_string(item, nil, false)
			end
			return post_string
		end
		def buildMessages(messages_stream)
			messages_string = "\n"
			for item in messages_stream do
				@source_name, @source_link = objectSource(item)
				messages_string << create_content_string(item, checkins_annotations(item), false) # create_content_string(item, annotations, me_mentioned)
			end
			last_viewed = messages_stream.last
			last_id = last_viewed['pagination_id'] unless last_viewed == nil
			return messages_string, last_id
		end
		def buildCompleteStream(post_hash)
			post_string = ""
			pagination_array = []
			saved_tags = []
			if $tools.config['skipped']['hashtags'] != nil
				for tag in $tools.config['skipped']['hashtags'] do
					saved_tags << tag.downcase
				end
			end
			for item in post_hash do
				pagination_array.push(item['pagination_id'])
				next if item['text'] == nil
				@source_name, @source_link = objectSource(item)
				case @source_name
				when *$tools.config['skipped']['sources']
					next
				end
				next if skip_hashtags(item, saved_tags)
				postMentionsArray = []
				@skipped_mentions_encountered = false
				for mention in item['entities']['mentions'] do
					case mention['name']
					when *$tools.config['skipped']['mentions']
						@skipped_mentions_encountered = true
						next
					end
					postMentionsArray.push(mention['name'])
				end
				next if @skipped_mentions_encountered == true
				me_mentioned = false
				for name in postMentionsArray do
					me_mentioned = true if name == $tools.config['identity']['prefix']
				end
				post_string << create_content_string(item, checkins_annotations(item), me_mentioned)
			end
			return post_string, pagination_array
		end
		def buildSimplePost(post_hash)
			create_content_string(post_hash, nil, false)
		end
		def buildSimplePostInfo(post_hash)
			#the_post_id = post_hash['id']
			post_text = post_hash['text']
			post_URL = post_hash['canonical_url']
			post_details = "\nPost URL: ".cyan + post_URL.brown + "\n"
			is_reply = post_hash['reply_to']
			if is_reply != nil
				post_details << "This post is a reply to post ".cyan + is_reply.brown + "\n"
			end
			if post_text != nil
				without_braces = $tools.withoutSquareBraces($tools.getMarkdownText(post_text.dup))
				post_details << "\nLength: ".cyan + without_braces.length.to_s.reddish
			end
			return post_details + "\n\n"
		end
		def buildPostInfo(post_hash, is_mine)
			post_text = post_hash['text']
			post_text != nil ? (colored_post = $tools.colorize(post_text)) : (puts "--Post deleted--\n\n".red; exit)
			user_name, user_real_name, the_name = objectNames(post_hash['user'])
			#user_follows = post_hash['follows_you']
			#user_followed = post_hash['you_follow']
			created_day, created_hour = objectDate(post_hash)
			post_details = "\n" + created_day.cyan + ' ' + created_hour.cyan + ' ' + the_name.green
			if !user_real_name.empty?
				post_details << " [#{user_real_name}]".reddish
			end
			post_details << ":\n"
			post_details << "\n" + colored_post + "\n\n" 
			post_details << "ID: ".cyan + post_hash['id'].to_s.green + "\n"
			post_details << objectLinks(post_hash) + "\n"
			post_details << "Post URL: ".cyan + post_hash['canonical_url'].brown
			is_reply = post_hash['reply_to']
			repost_of = post_hash['repost_of']
			if is_reply != nil
				post_details << "\nThis post is a reply to post ".cyan + is_reply.brown
			end
			if is_mine == false
				if repost_of != nil
					post_details << "\nThis post is a repost of post ".cyan + repost_of['id'].brown
				else
					post_details << "\nReplies: ".cyan + post_hash['num_replies'].to_s.reddish
					post_details << "  Reposts: ".cyan + post_hash['num_reposts'].to_s.reddish
					post_details << "  Stars: ".cyan + post_hash['num_stars'].to_s.reddish
				end
				if post_hash['you_reposted'] == true
					post_details << "\nYou reposted this post.".cyan
				end
				if post_hash['you_starred'] == true
					post_details << "\nYou starred this post.".cyan
				end
				post_details << "\nPosted with: ".cyan + post_hash['source']['name'].reddish
				post_details << "  Locale: ".cyan + post_hash['user']['locale'].reddish
				post_details << "  Timezone: ".cyan + post_hash['user']['timezone'].reddish
			else
				without_braces = $tools.withoutSquareBraces($tools.getMarkdownText(post_text.dup))
				post_details << "\nLength: ".cyan + without_braces.length.to_s.reddish
			end
			post_details << "\n\n\n"
		end
		def buildUsersList(users_hash)
			users_string = "\n"
			users_hash.each do |item|
				user_name, user_real_name, user_handle = objectNames(item)
				users_string << user_handle.green + " #{user_real_name}\n".cyan
			end
			users_string << "\n\n"
		end
		def buildFollowList
			#hashes = getDataNormal(@hash)
			#pagination_array = []
			users_hash = {}
			@hash['data'].each do |item|
				user_name, user_real_name, user_handle = objectNames(item)
				#pagination_array.push(item['pagination_id'])
				users_hash[user_handle] = user_real_name
			end
			#return users_hash, pagination_array
			return users_hash, @hash['meta']['min_id']
		end
		def buildFileInfo(resp_hash, with_url)
			created_day, created_hour = objectDate(resp_hash)
			list_string = ""
			file_name, file_token, file_source_name, file_source_url, file_kind, file_id, file_size, file_size_converted, file_public = filesDetails(resp_hash)
			#file_url_expires = resp_hash['url_expires']
			#derived_files = resp_hash['derived_files']
			# list_string += "\nID: ".cyan + file_id.brown
			list_string = file_view(file_name, file_kind, file_size, file_size_converted, file_source_name, file_source_url, created_day, created_hour)
			if file_public
				list_string << "\nThis file is ".cyan + "public".blue
				file_url = resp_hash['url_permanent']
			else
				list_string << "\nThis file is ".cyan + "private".red
				file_url = resp_hash['url']
			end
			if with_url
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
				#file_url_expires = item['url_expires']
				#derived_files = item['derived_files']
				list_string << "\nID: ".cyan + file_id.brown
				list_string << file_view(file_name, file_kind, file_size, file_size_converted, file_source_name, file_source_url, created_day, created_hour)
				if file_public
					list_string << "\nThis file is ".cyan + "public".blue
					list_string << "\nLink: ".cyan + item['url_short'].magenta
				else
					list_string << "\nThis file is ".cyan + "private".red
					if with_url
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
		def buildUserInfos(name, adn_data)
			user_name, user_real_name, the_name = objectNames(adn_data)
			user_show = "\nID: ".cyan.ljust(21) + adn_data['id'].green + "\n"
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
			user_show << "Posts: ".cyan.ljust(21) + adn_data['counts']['posts'].to_s.green + "\n" + "Followers: ".cyan.ljust(21) + adn_data['counts']['followers'].to_s.green + "\n" + "Following: ".cyan.ljust(21) + adn_data['counts']['following'].to_s.green + "\n"
			user_show << "Web: ".cyan.ljust(21) + "http://".green + adn_data['verified_domain'].green + "\n" if adn_data['verified_domain'] != nil
			user_show << "\n"
			user_show << the_name.brown
			if name != "me"
				if adn_data['follows_you']
					user_show << " follows you\n".green
				else
					user_show << " doesn't follow you\n".reddish
				end
				if adn_data['you_follow']
					user_show << "You follow ".green + the_name.brown + "\n"
				else
					user_show << "You don't follow ".reddish + the_name.brown + "\n"
				end
				if adn_data['you_muted']
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