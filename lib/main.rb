#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def initialize(token)
		@token = token
		@api = AyaDN::API.new(@token)
		@view = AyaDN::View
		@last_page_id_path = $tools.ayadn_configuration[:last_page_id_path]
		@progress_indicator = $tools.ayadn_configuration[:progress_indicator]
	end
	def stream
		$files.makedir(@last_page_id_path)
	 	puts @view.new(@hash).showStream
	end
	def completeStream
		$files.makedir(@last_page_id_path)
	    stream, pagination_array = @view.new(@hash).showCompleteStream
	    last_page_id = pagination_array.last
	    puts "\n" if last_page_id != nil
		return stream, last_page_id
	end
	def displayStream(stream)
		!stream.empty? ? (puts stream) : (puts $status.noNewPosts)
	end
	def displayScrollStream(stream)
		!stream.empty? ? (puts stream) : (print "\r")
	end
	def ayadnScroll(value, target)
		@progress_indicator = true
		value = "unified" if value == nil
		if target == nil
			fileURL = @last_page_id_path + "/last_page_id-#{value}"
		else
			fileURL = @last_page_id_path + "/last_page_id-#{value}-#{target}"
		end
		loop do
			begin
				print "\r                                         \r"
				#puts "\n"
				last_page_id = $files.get_last_page_id(fileURL)
				case value
				when "unified"
					@hash = @api.getUnified(last_page_id)
				when "global"
					@hash = @api.getGlobal(last_page_id)
				when "checkins", "photos", "conversations", "trending"
					@hash = @api.getExplore(value, last_page_id)
				when "mentions"
					@hash = @api.getUserMentions(target, last_page_id)
				when "posts"
					@hash = @api.getUserPosts(target, last_page_id)
				end
				# todo: color post id if I'm mentioned
				stream, last_page_id = completeStream
				displayScrollStream(stream)
				@progress_indicator = false
				if last_page_id != nil
					$files.write_last_page_id(fileURL, last_page_id)
					print "\r                                         "
            		puts "\n"
            		$tools.countdown($tools.config['timeline']['countdown_1'])
            	else
        			print "\rNo new posts                ".red
        			sleep 2
        			$tools.countdown($tools.config['timeline']['countdown_2'])
        		end					
			rescue Exception
				abort($status.stopped)
			end
		end
	end
	def ayadnInteractions
		puts $status.getInteractions
		puts @view.new(@api.getInteractions).showInteractions + "\n\n"
	end
	def ayadnGlobal(count=nil)
		puts $status.getGlobal
		fileURL = @last_page_id_path + "/last_page_id-global"
		$tools.config['counts']['global'] = count if count != nil
		@hash = @api.getGlobal($files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
		puts "\n"
	end
	def ayadnUnified(count=nil)
		fileURL = @last_page_id_path + "/last_page_id-unified"
		puts $status.getUnified
		$tools.config['counts']['unified'] = count if count != nil
		@hash = @api.getUnified($files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
		puts "\n"
	end
	def ayadnHashtags(tag)
		puts $status.getHashtags(tag)
		@hash = @api.getHashtags(tag)
		stream, last_page_id = completeStream
		displayStream(stream)
		puts "\n"
	end
	def ayadnExplore(explore, count=nil)
		fileURL = @last_page_id_path + "/last_page_id-#{explore}"
		puts $status.getExplore(explore)
		$tools.config['counts']['explore'] = count if count != nil
		@hash = @api.getExplore(explore, $files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
		puts "\n"
	end
	def ayadnUserMentions(name, count=nil)
		fileURL = @last_page_id_path + "/last_page_id-mentions-#{name}"
		puts $status.mentionsUser(name)
		$tools.config['counts']['mentions'] = count if count != nil
		@hash = @api.getUserMentions(name, $files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
		puts "\n"
	end
	def ayadnUserPosts(name, count=nil)
		fileURL = @last_page_id_path + "/last_page_id-posts-#{name}"
		puts $status.postsUser(name)
		$tools.config['counts']['posts'] = count if count != nil
		@hash = @api.getUserPosts(name, $files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUserInfos(name)
		puts $status.infosUser(name)
	    puts @view.new(@api.getUserInfos(name)).showUsersInfos(name)
	end
	def get_loaded_channels
		loaded_channels = $files.load_channels
		channels_with_messages = $files.load_channels_with_messages
		if loaded_channels != nil
			puts "Backed-up list of your active channels:\n".green
			loaded_channels.each do |k,v|
				puts "Channel: ".cyan + k.brown
				puts "Title: ".cyan + v.magenta
				if channels_with_messages != nil && channels_with_messages[k] != nil
					puts "Last message by @#{channels_with_messages[k]['username']} (#{channels_with_messages[k]['message_date']}): \n".cyan + channels_with_messages[k]['text']
				end
				puts "\n"
			end
			puts "Do you want to refresh the list? (y/N)".green
			abort("\nCanceled.\n\n".red) unless STDIN.getch == ("y" || "Y")
			puts "\n"
		end
	end
	def ayadn_get_channels
		@hash = @api.get_pm_channels
		the_channels, channels_list = @view.new(@hash).show_pm_channels
		puts the_channels
		@hash = @api.get_channels
		the_channels, channels_list = @view.new(@hash).show_channels
		puts the_channels
	end
	def ayadnGetMessages(target, action = nil)
		$files.makedir($tools.ayadn_configuration[:messages_path])
		@progress_indicator = false
		if target != nil
			fileURL = @last_page_id_path + "/last_page_id-channels-#{target}"
			last_page_id = $files.get_last_page_id(fileURL) unless action == "all"
			messages_string, last_page_id = @view.new(@api.getMessages(target, last_page_id)).showMessagesFromChannel
			$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
			displayStream(messages_string)
		else
			puts $status.errorSyntax
		end
	end

	def ayadnDeletePost(postID)
		puts $status.deletePost(postID)
		if @api.goDelete(postID) == nil
			abort($status.errorAlreadyDeleted)
		else
			$tools.checkHTTPResp(@api.clientHTTP("delete"))
			puts $status.postDeleted
			exit
		end
	end
	def ayadn_delete_message(channel_id, message_id)
		puts "\nDeleting message #{message_id} in channel #{channel_id}".green
		@url = @api.unique_message(channel_id, message_id)
		$tools.checkHTTPResp(@api.clientHTTP("delete"))
		puts "\nDone!\n".green
	end

	def ayadnWhoReposted(postID)
		puts $status.whoReposted(postID)
		@hash = @api.getWhoReposted(postID)
		abort($status.errorNobodyReposted) if @hash['data'].empty?
	    puts @view.new(@hash).showUsersList
	end
	def ayadnWhoStarred(postID)
		puts $status.whoStarred(postID)
		@hash = @api.getWhoStarred(postID)
		abort($status.errorNobodyStarred) if @hash['data'].empty?
	    puts @view.new(@hash).showUsersList
	end
	def ayadnStarredPosts(name, count=nil)
		puts $status.starsUser(name)
		$tools.config['counts']['starred'] = count if count != nil
		@hash = @api.getStarredPosts(name)
		stream, last_page_id = completeStream
		displayStream(stream)
	end
	def ayadnConversation(postID)
		puts $status.getPostReplies(postID)
		@hash = @api.getPostReplies(postID)
		stream, last_page_id = completeStream
		displayStream(stream)
	end
	def ayadnPostInfos(postID)
		puts $status.infosPost(postID)
	    puts @view.new(@api.getPostInfos(postID)).showPostInfos(postID, isMine = false)
	end
	def ayadnLoadPost(postID)
		puts $status.infosPost(postID)
		puts @view.new(nil).buildPostInfo(load_post(postID), true)
	end
	def load_post(post_id)
		fileContent = {}
		File.open("#{$tools.ayadn_configuration[:posts_path]}/#{post_id}.post", "r") do |f|
			fileContent = f.gets
		end
		resp = eval(fileContent)
	end
	def ayadnSavePost(postID)
		@progress_indicator = false
		name = postID.to_s
		$files.makedir($tools.ayadn_configuration[:posts_path])
		file = "/#{name}.post"
		fileURL = $tools.ayadn_configuration[:posts_path] + file
		abort("\nYou already saved this post.\n\n".red) if File.exists?(fileURL)
		puts "\nLoading post from App.net...".green + name.brown
		puts $status.savingFile(name, $tools.ayadn_configuration[:posts_path], file)
		f = File.new(fileURL, "w")
			f.puts(@api.getSinglePost(postID))
		f.close
		puts "\nSuccessfully saved the post.\n\n".green
		exit
	end

	def ayadnSearch(value)
		@hash = @api.getSearch(value)
		stream, last_page_id = completeStream
		displayStream(stream)
	end

	def ayadnFollowing(action, name)
		@progress_indicator = false
		you_follow, follows_you = @api.getUserFollowInfo(name)
		if action == "follow"
			if you_follow
				abort("You're already following this user.\n\n".red)
			else
				@api.followUser(name)
				puts "\nYou just followed user ".green + "#{name}".brown + "\n\n"
			end
		elsif action == "unfollow"
			if you_follow
				@api.unfollowUser(name)
				puts "\nYou just unfollowed user ".green + "#{name}".brown + "\n\n"
			else
				abort("You're already not following this user.\n\n".red)
			end
		else
			abort($status.errorSyntax)
		end
	end

	def ayadnMuting(action, name)
		@progress_indicator = false
		you_muted = @api.getUserMuteInfo(name)
		if action == "mute"
			if you_muted
				abort("You've already muted this user.\n\n".red)
			else
				@api.muteUser(name)
				puts "\nYou just muted user ".green + "#{name}".brown + "\n\n"
			end
		elsif action == "unmute"
			if you_muted
				@api.unmuteUser(name)
				puts "\nYou just unmuted user ".green + "#{name}".brown + "\n\n"
			else
				abort("This user is not muted.\n\n".red)
			end
		else
			abort($status.errorSyntax)
		end
	end

	def ayadnStarringPost(action, postID)
		@progress_indicator = false
		@hash = @api.getSinglePost(postID)
		post_data = @hash['data']
		you_starred = post_data['you_starred']
		is_repost = post_data['repost_of']
		if is_repost != nil
			puts $status.errorIsRepost(postID)
			puts "Redirecting to the original post.\n".cyan
			postID = is_repost['id']
			you_starred = is_repost['you_starred']
		end
		if action == "star"
			if you_starred == false
				puts "\nStarring post ".green + "#{postID}\n".brown
				@api.starPost(postID)
				puts "\nSuccessfully starred the post.\n\n".green
			else
				abort("Canceled: the post is already starred.\n\n".red)
			end
		elsif action == "unstar"
			if you_starred == false
				abort("Canceled: the post wasn't already starred.\n\n".red)
			else
				puts "\nUnstarring post ".green + "#{postID}\n".brown
				@api.unstarPost(postID)
				puts "\nSuccessfully unstarred the post.\n\n".green
			end
		else
			abort("\nsyntax error\n".red)
		end
	end
	def ayadnReposting(action, postID)
		@progress_indicator = false
		@hash = @api.getSinglePost(postID)
		post_data = @hash['data']
		is_repost = post_data['repost_of']
		you_reposted = post_data['you_reposted']
		if is_repost != nil && you_reposted == false
			puts $status.errorIsRepost(postID)
			puts "Redirecting to the original post.\n".cyan
			postID = is_repost['id']
			you_reposted = is_repost['you_reposted']
		end
		if action == "repost"
			if you_reposted
				abort("Canceled: you already reposted this post.\n\n".red)
			else
				puts "\nReposting post ".green + "#{postID}\n".brown
				@api.repostPost(postID)
				puts "\nSuccessfully reposted the post.\n\n".green
			end
		elsif action == "unrepost"
			if you_reposted
				puts "\nUnreposting post ".green + "#{postID}\n".brown
				@api.unrepostPost(postID)
				puts "\nSuccessfully unreposted the post.\n\n".green
			else
				abort("Canceled: this post wasn't reposted by you.\n\n".red)
			end
		else
			abort($status.errorSyntax)
		end
	end
	def ayadnReset(content, option)
		$files.reset_pagination(content, option)
	end
	def ayadn_show_options
		puts "\nCurrent options in ".cyan + "config.yml\n".magenta
		$tools.config.each do |k,v|
			puts "#{k.capitalize}:".cyan
			v.each do |x,y|
				puts "\t#{x.green} => #{y.to_s.brown}"
			end
		end
		puts "\n"
		puts "AyaDN local data: \n".magenta
		puts "Posts path:".cyan
		puts "\t" + $tools.ayadn_configuration[:posts_path].brown + "/".brown
		puts "Messages path:".cyan
		puts "\t" + $tools.ayadn_configuration[:messages_path].brown + "/".brown
		puts "Lists path:".cyan
		puts "\t" + $tools.ayadn_configuration[:lists_path].brown + "/".brown
		puts "Files path:".cyan
		puts "\t" + $tools.ayadn_configuration[:files_path].brown + "/".brown
		puts "Database path:".cyan
		puts "\t" + $tools.ayadn_configuration[:db_path].brown + "/".brown
		puts "\n"
		puts "AyaDN system configuration: \n".magenta
		puts "Authorization token path:".cyan
		puts "\t" + $tools.ayadn_configuration[:authorization_path].brown + "/".brown
		puts "API configuration path:".cyan
		puts "\t" + $tools.ayadn_configuration[:api_config_path].brown + "/".brown
		puts "Pagination data path:".cyan
		puts "\t" + $tools.ayadn_configuration[:last_page_id_path].brown + "/".brown
		puts "Detected platform:".cyan
		puts "\t" + $tools.ayadn_configuration[:platform].brown
		puts "\n"
	end
end