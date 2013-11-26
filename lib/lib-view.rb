#!/usr/bin/ruby
# encoding: utf-8
class AyaDN
	class View < Tools
		def initialize(hash)
			@hash = hash
			@configFileContents, @loaded = loadConfig
		end
		def getData(hash)
			adnData = @hash['data']
			adnDataReverse = adnData.reverse
		end
		def getDataNormal(hash)
			adnData = @hash['data']
		end
		def showMessagesFromChannel
			messagesStream = getData(@hash)
			buildMessages(messagesStream)
		end
		def showStream
			if @loaded
				downsideTimeline = @configFileContents['timeline']['downside']
				if downsideTimeline == true
					hashes = getData(@hash)
				else
					hashes = getDataNormal(@hash)
				end
			else
				hashes = getData(@hash)
			end
			buildStream(hashes)
		end
		def showCompleteStream
			if @loaded
				downsideTimeline = @configFileContents['timeline']['downside']
				if downsideTimeline == true
					hashes = getData(@hash)
				else
					hashes = getDataNormal(@hash)
				end
			else
				hashes = getData(@hash)
			end
			stream, pagination_array = buildCompleteStream(hashes)
		end
		def showDebugStream
			hashes = getDataNormal(@hash)
			buildDebugStream(hashes)
		end

		def showUsersList
			hashes = getData(@hash)
			buildUsersList(hashes)
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
		def buildStream(postHash)
			postString = ""
			postHash.each do |item|
				postText = item['text']
				if postText != nil
					coloredPost = colorize(postText)
				else
					coloredPost = "--Post deleted--".red
				end
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
					coloredPost = colorize(messageText)
				else
					coloredPost = "--Message deleted--".red
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
			return messagesString
		end
		def buildCompleteStream(postHash)
			postString = ""
			geoString = ""
			pagination_array = []
			postHash.each do |item|
				pagination_array.push(item['pagination_id'])
				postText = item['text']
				if postText != nil
					coloredPost = colorize(postText)
				else
					coloredPost = "--Post deleted--".red
				end
				userName = item['user']['username']
				createdAt = item['created_at']
				createdDay = createdAt[0...10]
				createdHour = createdAt[11...19]
				postId = item['id']
				postString += "PostID: ".cyan + postId.to_s.green
				postString += " - "
				postString += createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".reddish + userName.reddish + "\n" + coloredPost + "\n"
				links = item['entities']['links']
				sourceName = item['source']['name']
				sourceLink = item['source']['link']
				# plusieurs annotations par post, dont checkin
				annoList = item['annotations']
				xxx = 0
				#if annoList.length > 0
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
							#if !links.empty?
							postString += "\n"
							#end
							#todo:
							#chCategories
						end
						xxx += 1
					end
				end
				if !links.empty?
					#postString += "\n"
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
		def buildPostInfo(postHash, isMine)
			thePostId = postHash['id']
			postText = postHash['text']
			userName = postHash['user']['username']
			realName = postHash['user']['name']
			theName = "@" + userName
			userFollows = postHash['follows_you']
			userFollowed = postHash['you_follow']
			
			coloredPost = colorize(postText)

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
				withoutMarkdown = getMarkdownText(toRegex)
				withoutBraces = withoutSquareBraces(withoutMarkdown)
				actualLength = withoutBraces.length
				postDetails += "\nLength: ".cyan + actualLength.to_s.reddish
			end
			postDetails += "\n\n"
		end
		def buildUsersList(usersHash)
			usersString = ""
			usersHash.each do |item|
				userName = item['username']
				userRealName = item['name']
				userHandle = "@" + userName
				usersString += userHandle.green + " #{userRealName}\n".cyan
				# pagi = item['pagination_id']
				# usersString += pagi + "\n"
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