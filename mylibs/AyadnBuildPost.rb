class AyaDN
	class BuildPosts
		def colorize(contentText)
			content = Array.new
			splitted = contentText.split(" ")
			splitted.each do |word|
				if word =~ /^#/
					content.push(word.blue)
				elsif word =~ /^@/
					content.push(word.red)
				elsif word =~ /^http/ or word =~ /^photos.app.net/ or word =~ /^files.app.net/ or word =~ /^chimp.li/ or word =~ /^bli.ms/
					content.push(word.magenta)
				else
					content.push(word)
				end
			end
			coloredPost = content.join(" ")
		end
		def buildPost(postHash)
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
		def buildUniquePost(postHash)
			postString = ""
			postText = postHash['text']
			if postText != nil
				coloredPost = colorize(postText)
			else
				coloredPost = "--Post deleted--".red
			end
			userName = postHash['user']['username']
			createdAt = postHash['created_at']
			createdDay = createdAt[0...10]
			createdHour = createdAt[11...19]
			links = postHash['entities']['links']
			postId = postHash['id']
			postString += "\n\nPost ID: ".cyan + postId.to_s.green
			postString += " - " + createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green + "\n\n" + coloredPost + "\n" + "\n"
			if !links.empty?
				postString += "Link: ".cyan
				links.each do |link|
					linkURL = link['url']
					postString += linkURL.brown + " "
				end
			end
			postString += "\n\n"
			return postString
		end
		def buildCheckinsPosts(postHash)
			postString = ""
			geoString = ""
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
				postId = item['id']
				postString += "Post ID: ".cyan + postId.to_s.green
				postString += " - "
				postString += createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green + "\n" + coloredPost + "\n"
				links = item['entities']['links']
				sourceName = item['source']['name']
				sourceLink = item['source']['link']
				# plusieurs annotations par post, dont checkin
				annoList = item['annotations']
				xxx = 0
				if annoList.length > 0
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
								postString += "\n-Name: ".cyan + chName.upcase.reddish
							end
							unless chAddress.nil?
								postString += "\n-Address: ".cyan + chAddress.green
							end
							unless chLocality.nil?
								postString += "\n-Locality: ".cyan + chLocality.green
							end
							unless chPostcode.nil?
								postString += " (#{chPostcode})".green
							end
							unless chRegion.nil?
								postString += "\n-State/Region: ".cyan + chRegion.green
							end
							unless chCountryCode.nil?
								postString += " (#{chCountryCode})".upcase.green
							end
							unless sourceName.nil?
								postString += "\n-Posted with: ".cyan + "#{sourceName} [#{sourceLink}]".green
							end
							if !links.empty?
								postString += "\n-Internal link: ".cyan
								links.each do |link|
									linkURL = link['url']
									postString += linkURL.brown
								end
							end
							#todo:
							#chCategories
						end
						xxx += 1
					end
				end
				postString += "\n\n"
			end
			return postString
		end
	end
end