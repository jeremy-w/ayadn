#!/usr/bin/ruby
# encoding: utf-8
class AyaDN
	class View
		def initialize(hash)
			@hash = hash
		end
		def getData(hash)
			adnData = @hash['data']
			adnDataReverse = adnData.reverse
		end
		def getDataNormal(hash)
			adnData = @hash['data']
		end
		def showMessagesFromChannel
			buildMessages(getData(@hash))
		end
		def showStream
			if $loaded
				if $downsideTimeline == true
					theHash = getData(@hash)
				else
					theHash = getDataNormal(@hash)
				end
			else
				theHash = getData(@hash)
			end
			buildStream(theHash)
		end
		def showCompleteStream
			if $loaded
				if $downsideTimeline == true
					theHash = getData(@hash)
				else
					theHash = getDataNormal(@hash)
				end
			else
				theHash = getData(@hash)
			end
			stream, pagination_array = buildCompleteStream(theHash)
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
			sortedHash = @hash.sort
			sortedHash.each do |handle, name|
				users += "#{handle}".red + " - " + "#{name}\n".cyan
			end
			hashLength = @hash.length
			return users, hashLength
		end

		def showUsersInfos(name)
			adnData = @hash['data']
			buildUserInfos(name, adnData)
		end
		def showPostInfos(postId, isMine)
			postHash = @hash['data']
			buildPostInfo(postHash, isMine)
		end
		def buildDebugStream(postHash)
			retString = ""
			postHash.each do |k, v|
				retString += "#{k}: #{v}\n\n"
			end
			return retString
		end
		def buildInteractions(hash)
			inter_string = ""
			hash.each do |item|
				action = item['action']
				event_date = item['event_date']
				createdDay = event_date[0...10]
				createdHour = event_date[11...19]
				objects_names, users_list, post_ids, post_text = [], [], [], []
				objects = item['objects']
				obj_has_names = false
				objects.each do |o|
					case action
					when "follow", "unfollow", "mute", "unmute"
						object_user_names = "@" + o['username']
						objects_names.push(object_user_names)
					when "star", "unstar", "repost", "unrepost", "reply"
						postID = o['id']
						post_ids.push(postID)
						#text = o['text']
						post_info = buildPostInfo(o, false)
						post_text.push(post_info.chomp("\n\n"))
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
				inter_string += "Date: ".green + "#{createdDay} #{createdHour}\n".cyan
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
		def buildStream(postHash)
			postString = ""
			postHash.each do |item|
				postText = item['text']
				postText != nil ? (coloredPost = $tools.colorize(postText)) : (coloredPost = "--Post deleted--".red)
				userName = item['user']['username']
				createdAt = item['created_at']
				createdDay = createdAt[0...10]
				createdHour = createdAt[11...19]
				links = item['entities']['links']
				postId = item['id']
				postString += "Post ID: ".cyan + postId.to_s.green
				postString += " - "
				postString += createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green + "\n" + coloredPost + "\n"
				if !links.empty?
					postString += "Link: ".cyan
					links.each do |link|
						linkURL = link['url']
						postString += linkURL.brown + " \n"
					end
				end
				postString += "\n\n"
			end
			return postString
		end
		def buildMessages(messagesStream)
			messagesString = ""
			messagesStream.each do |item|
				messageText = item['text']
				if messageText != nil
					coloredPost = $tools.colorize(messageText)
				else
					coloredPost = "--Message deleted--".red
					#next
				end
				createdAt = item['created_at']
				createdDay = createdAt[0...10]
				createdHour = createdAt[11...19]
				links = item['entities']['links']
				userName = item['user']['username']
				postId = item['id']
				messagesString += "Post ID: ".cyan + postId.to_s.green
				messagesString += " - "
				messagesString += createdDay.cyan + ' ' + createdHour.cyan + " by " + "@".green + userName.green + "\n" + coloredPost + "\n"
				if !links.empty?
					messagesString += "Link: ".cyan
					links.each do |link|
						linkURL = link['url']
						messagesString += linkURL.brown + " \n"
					end
				end
				messagesString += "\n"
			end
			lastViewed = messagesStream.last
			lastID = lastViewed['pagination_id'] unless lastViewed == nil
			return messagesString, lastID
		end
		def buildCompleteStream(postHash)
			postString = ""
			geoString = ""
			pagination_array = []
			postHash.each do |item|
				pagination_array.push(item['pagination_id'])
				postText = item['text']
				postId = item['id']
				sourceName = item['source']['name']

				# Skip sources
				# case sourceName
				# when *$skipped_sources
					# postString += "Post ID: ".cyan + postId.to_s.green
					# postString += " -" + " SKIPPED".cyan
					# matched = $skipped_sources.index(sourceName)
					# postString += " \"#{$skipped_sources[matched]}\"\n\n".cyan
				# 	next
				# end

				if postText != nil
					coloredPost = $tools.colorize(postText)
				else
					coloredPost = "--Post deleted--".red
				end
				userName = item['user']['username']
				createdAt = item['created_at']
				createdDay = createdAt[0...10]
				createdHour = createdAt[11...19]
				postString += "Post ID: ".cyan + postId.to_s.green
				postString += " - "
				postString += createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".reddish + userName.reddish + "\n" + coloredPost + "\n"
				links = item['entities']['links']

				sourceLink = item['source']['link']
				annoList = item['annotations']
				xxx = 0
				if annoList != nil
					annoList.each do |it|
						annoType = annoList[xxx]['type']
						annoValue = annoList[xxx]['value']
						if annoType == "net.app.core.checkin" or annoType == "net.app.ohai.location"
							chName = annoValue['name']
							chAddress = annoValue['address']
							chLocality = annoValue['locality']
							chRegion = annoValue['region']
							chPostcode = annoValue['postcode']
							chCountryCode = annoValue['country_code']
							fancy = chName.length + 7
							postString += "." * fancy #longueur du nom plus son étiquette
							unless chName.nil?
								postString += "\nName: ".cyan + chName.upcase.reddish
							end
							unless chAddress.nil?
								postString += "\nAddress: ".cyan + chAddress.green
							end
							unless chLocality.nil?
								postString += "\nLocality: ".cyan + chLocality.green
							end
							unless chPostcode.nil?
								postString += " (#{chPostcode})".green
							end
							unless chRegion.nil?
								postString += "\nState/Region: ".cyan + chRegion.green
							end
							unless chCountryCode.nil?
								postString += " (#{chCountryCode})".upcase.green
							end
							unless sourceName.nil?
								postString += "\nPosted with: ".cyan + "#{sourceName} [#{sourceLink}]".green + " "
							end
							postString += "\n"
						end
						xxx += 1
					end
				end
				if !links.empty?
					links.each do |link|
						linkURL = link['url']
						postString += "Link: ".cyan + linkURL.brown + " "
					end
					postString += "\n"
				end
				postString += "\n"
			end
			return postString, pagination_array
		end
		def buildSimplePost(postHash)
			postText = postHash['text']
			if postText != nil
				coloredPost = $tools.colorize(postText)
			else
				coloredPost = "--Post deleted--".red
			end
			userName = postHash['user']['username']
			createdAt = postHash['created_at']
			createdDay = createdAt[0...10]
			createdHour = createdAt[11...19]
			postId = postHash['id']
			postString = "Post ID: ".cyan + postId.to_s.red.reverse_color
			postString += " - "
			postString += createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".reddish + userName.reddish + "\n" + coloredPost + "\n"
			links = postHash['entities']['links']
			sourceName = postHash['source']['name']
			sourceLink = postHash['source']['link']
			if !links.empty?
				links.each do |link|
					linkURL = link['url']
					postString += "Link: ".cyan + linkURL.brown + " "
				end
				postString += "\n"
			end
			postString += "\n"
		end
		def buildSimplePostView(postHash)
			thePostId = postHash['id']
			postText = postHash['text']
			userName = postHash['user']['username']
			realName = postHash['user']['name']
			theName = "@" + userName
			coloredPost = $tools.colorize(postText)
			createdAt = postHash['created_at']
			createdDay = createdAt[0...10]
			createdHour = createdAt[11...19]
			postDetails = createdDay.cyan + " " + thePostId.green + " " + theName.brown
			if !realName.empty?
				postDetails += " #{realName}".pink
			end
			postDetails += "\n" + coloredPost + "\n\n"
		end
		def buildPostInfo(postHash, isMine)
			thePostId = postHash['id']
			postText = postHash['text']
			userName = postHash['user']['username']
			realName = postHash['user']['name']
			theName = "@" + userName
			userFollows = postHash['follows_you']
			userFollowed = postHash['you_follow']
			
			coloredPost = $tools.colorize(postText)

			createdAt = postHash['created_at']
			createdDay = createdAt[0...10]
			createdHour = createdAt[11...19]
			links = postHash['entities']['links']

			postDetails = "\nThe " + createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green
			if !realName.empty?
				postDetails += " \[#{realName}\]".reddish
			end
			postDetails += ":\n"
			postDetails += "\n" + coloredPost + "\n" + "\n" 
			postDetails += "Post ID: ".cyan + thePostId.to_s.green
			if !links.empty?
				links.each do |link|
					linkURL = link['url']
					postDetails += "\nLink: ".cyan + linkURL.brown
				end
			else
				#postDetails += "\n"
			end
			postURL = postHash['canonical_url']

			postDetails += "\nPost URL: ".cyan + postURL.brown

			numStars = postHash['num_stars']
			numReplies = postHash['num_replies']
			numReposts = postHash['num_reposts']
			youReposted = postHash['you_reposted']
			youStarred = postHash['you_starred']
			sourceApp = postHash['source']['name']
			locale = postHash['user']['locale']
			timezone = postHash['user']['timezone']
			isReply = postHash['reply_to']
			repostOf = postHash['repost_of']
			if isReply != nil
				postDetails += "\nThis post is a reply to post ".cyan + isReply.brown
			end

			if isMine == false
				if repostOf != nil
					repostID = repostOf['id']
					postDetails += "\nThis post is a repost of post ".cyan + repostID.brown
				else
					postDetails += "\nReplies: ".cyan + numReplies.to_s.reddish
					postDetails += "  Reposts: ".cyan + numReposts.to_s.reddish
					postDetails += "  Stars: ".cyan + numStars.to_s.reddish
				end
				if youReposted == true
					postDetails += "\nYou reposted this post.".cyan
				end
				if youStarred == true
					postDetails += "\nYou starred this post.".cyan
				end
				postDetails += "\nPosted with: ".cyan + sourceApp.reddish
				postDetails += "  Locale: ".cyan + locale.reddish
				postDetails += "  Timezone: ".cyan + timezone.reddish
			else
				toRegex = postText.dup
				withoutMarkdown = $tools.getMarkdownText(toRegex)
				withoutBraces = $tools.withoutSquareBraces(withoutMarkdown)
				actualLength = withoutBraces.length
				postDetails += "\nLength: ".cyan + actualLength.to_s.reddish
			end
			postDetails += "\n\n\n"
		end
		def buildUsersList(usersHash)
			usersString = ""
			usersHash.each do |item|
				userName = item['username']
				userRealName = item['name']
				userHandle = "@" + userName
				usersString += userHandle.green + " #{userRealName}\n".cyan
			end
			usersString += "\n\n"
		end
		def buildFollowList
			hashes = getDataNormal(@hash)
			pagination_array = []
			usersHash = {}
			hashes.each do |item|
				userName = item['username']
				userRealName = item['name']
				userHandle = "@" + userName
				pagination_array.push(item['pagination_id'])
				usersHash[userHandle] = userRealName
			end
			return usersHash, pagination_array
		end
		def showFileInfo(with_url)
			list_string = ""
			file_url = nil
			resp_hash = getDataNormal(@hash)
			file_name = resp_hash['name']
			file_token = resp_hash['file_token']
			file_source_name = resp_hash['source']['name']
			file_source_url = resp_hash['source']['link']
			file_created_at = resp_hash['created_at']
			created_day = file_created_at[0...10]
			created_hour = file_created_at[11...19]
			file_kind = resp_hash['kind']
			file_id = resp_hash['id']
			file_size = resp_hash['size']
			file_size_converted = file_size.to_filesize unless file_size == nil
			file_public = resp_hash['public']
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
				# if derived_files != nil
				# 	if derived_files['image_thumb_960r'] != nil
				# 		file_derived_bigthumb_name = derived_files['image_thumb_960r']['name']
				# 		file_derived_bigthumb_url = derived_files['image_thumb_960r']['url']
				# 	end
				# 	if derived_files['image_thumb_200s'] != nil
				# 		file_derived_smallthumb_name = derived_files['image_thumb_200s']['name']
				# 		file_derived_smallthumb_url = derived_files['image_thumb_200s']['url']
				# 	end
				# 	list_string += "\nBig thumbnail: ".cyan + file_derived_bigthumb_url unless file_derived_bigthumb_url == nil
				# 	list_string += "\nSmall thumbnail: ".cyan + file_derived_smallthumb_url unless file_derived_smallthumb_url == nil
				# end
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
				pagination_array.push(item['pagination_id'])
				file_name = item['name']
				file_token = item['file_token']
				file_source_name = item['source']['name']
				file_source_url = item['source']['link']
				file_created_at = item['created_at']
				created_day = file_created_at[0...10]
				created_hour = file_created_at[11...19]
				file_kind = item['kind']
				file_id = item['id']
				file_size = item['size']
				file_size_converted = file_size.to_filesize unless file_size == nil
				file_public = item['public']
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
				else
					list_string += "\nThis file is ".cyan + "private".red
				end
				if with_url == true
					file_url = item['url_permanent']
					list_string += "\nURL: ".cyan + file_url.brown
					# if derived_files != nil
					# 	if derived_files['image_thumb_960r'] != nil
					# 		file_derived_bigthumb_name = derived_files['image_thumb_960r']['name']
					# 		file_derived_bigthumb_url = derived_files['image_thumb_960r']['url']
					# 	end
					# 	if derived_files['image_thumb_200s'] != nil
					# 		file_derived_smallthumb_name = derived_files['image_thumb_200s']['name']
					# 		file_derived_smallthumb_url = derived_files['image_thumb_200s']['url']
					# 	end
					# 	list_string += "\nBig thumbnail: ".cyan + file_derived_bigthumb_url unless file_derived_bigthumb_url == nil
					# 	list_string += "\nSmall thumbnail: ".cyan + file_derived_smallthumb_url unless file_derived_smallthumb_url == nil
					# end
				end
				list_string += "\n"
			end
			list_string += "\n"
			return list_string, file_url, pagination_array
		end
		def buildChannelsInfos(hash)
			meta = hash['meta']
			unreadMessages = meta['unread_counts']['net.app.core.pm']
			data = hash['data']
			theChannels = ""
			channels_list = []
			puts "Getting users infos, please wait a few seconds... (could take a while if many channels)\n".cyan
			data.each do |item|
				channelID = item['id']
				channel_type = item['type']
				if channel_type == "net.app.core.pm"
					channels_list.push(channelID)
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
					# if readers != nil
					# 	readers.each do |reader|
					# 		the_readers.push(reader) 
					# 	end
					# end
					# if you_write
					# 	the_writers.push("yourself")
					# end
					theChannels += "\nChannel ID: ".cyan + "#{channelID}\n".brown
					theChannels += "Creator: ".cyan + owner.magenta + "\n"
					#theChannels += "Channels type: ".cyan + "#{channel_type}\n".brown
					theChannels += "Interlocutor(s): ".cyan + the_writers.join(", ").magenta + "\n"
					# theChannels += "Authorized: ".cyan + the_writers.join(", ").brown + "\n"
					# if readers != nil
					# 	theChannels += "Readers: ".cyan + the_readers.join(", ").brown + "\n"
					# else
					# 	theChannels += "Readers: ".cyan + "yourself\n".brown
					# end
					# if unreadMessages > 0
					# 	theChannels += "Unread messages: ".cyan + unreadMessages.to_s.reddish + "\n"
					# else
					# 	theChannels += "Unread messages: ".cyan + unreadMessages.to_s.green + "\n"
					# end
					# theChannels += "You can do ".pink + "ayadn pm #{owner} ".brown + "to send a private message.\n\n".pink
				end
				if channel_type == "com.ayadn.drafts"
					$drafts = channelID
					channels_list.push(channelID)
					theChannels += "\nChannel ID: ".cyan + "#{channelID}\n".brown + " -> " + "your AyaDN Drafts channel\n".green
				end
			end
			theChannels += "\n"
			return theChannels, channels_list
		end
		def buildUserInfos(name, adnData)
			userName = adnData['username']
			userShow = "\n--- @".brown + userName.brown + " ---\n".brown
			theName = "@" + userName
			userRealName = adnData['name']
			if userRealName != nil
				userShow += "Name: ".red + userRealName.cyan + "\n"
			end
			if adnData['description'] != nil
				userDescr = adnData['description']['text']
			else
				userDescr = "No description available.".red
			end
			userTimezone = adnData['timezone']
			if userTimezone != nil
				userShow += "Timezone: ".red + userTimezone.cyan + "\n"
			end
			locale = adnData['locale']
			if locale != nil
				userShow += "Locale: ".red + locale.cyan + "\n"
			end
			userShow += theName.red


			# this will be obsolete once the app has its own token
			if name != "me"
				userFollows = adnData['follows_you']
				userFollowed = adnData['you_follow']
				if userFollows == true
					userShow += " follows you\n".green
				else
					userShow += " doesn't follow you\n".reddish
				end
				if userFollowed == true
					userShow += "You follow ".green + theName.red
				else
					userShow += "You don't follow ".reddish + theName.red
				end
			else
				userShow += ":".red + " yourself!".cyan
			end
			#
			
			userPosts = adnData['counts']['posts']
			userFollowers = adnData['counts']['followers']
			userFollowing = adnData['counts']['following']
			userShow += "\nPosts: ".red + userPosts.to_s.cyan + "\nFollowers: ".red + userFollowers.to_s.cyan + "\nFollowing: ".red + userFollowing.to_s.cyan
			userShow += "\nBio: \n".red + userDescr + "\n\n"
		end
	end
end