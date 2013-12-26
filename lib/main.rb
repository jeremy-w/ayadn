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
				last_page_id = $files.get_last_page_id(fileURL)
				case value
				when "global"
					@hash = @api.getGlobal(last_page_id)
				when "unified"
					@hash = @api.getUnified(last_page_id)
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
            		puts "\n\n"
            		$tools.countdown($tools.config['timeline']['countdown_1'])
            	else
        			print "\rNo new posts                ".red
        			sleep 2
        			$tools.countdown($tools.config['timeline']['countdown_1'])
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
	def ayadnGlobal
		puts $status.getGlobal
		fileURL = @last_page_id_path + "/last_page_id-global"
		@hash = @api.getGlobal($files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUnified
		fileURL = @last_page_id_path + "/last_page_id-unified"
		puts $status.getUnified
		@hash = @api.getUnified($files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnHashtags(tag)
		puts $status.getHashtags(tag)
		@hash = @api.getHashtags(tag)
		stream, last_page_id = completeStream
		displayStream(stream)
	end
	def ayadnExplore(explore)
		fileURL = @last_page_id_path + "/last_page_id-#{explore}"
		puts $status.getExplore(explore)
		@hash = @api.getExplore(explore, $files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUserMentions(name)
		fileURL = @last_page_id_path + "/last_page_id-mentions-#{name}"
		puts $status.mentionsUser(name)
		@hash = @api.getUserMentions(name, $files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUserPosts(name)
		fileURL = @last_page_id_path + "/last_page_id-posts-#{name}"
		puts $status.postsUser(name)
		@hash = @api.getUserPosts(name, $files.get_last_page_id(fileURL))
		stream, last_page_id = completeStream
		$files.write_last_page_id(fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUserInfos(name)
		puts $status.infosUser(name)
	    puts @view.new(@api.getUserInfos(name)).showUsersInfos(name)
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
			loaded_channels = $files.load_channels
			if loaded_channels != nil
				puts "Backed-up list of your active channels:\n".green
				loaded_channels.each do |k,v|
					puts "Channel: ".cyan + k.brown
					puts "Title: ".cyan + v.magenta
					puts "\n"
				end
				puts "Do you want to see if you have more channels activated? (Y/n)".green
				abort("\nCanceled.\n\n".red) unless STDIN.getch == ("y" || "Y")
				puts "\n"
			end
			@hash = @api.getChannels
			the_channels, channels_list = @view.new(@hash).showChannels("net.app.core.pm")
			puts the_channels
			the_channels, channels_list = @view.new(@hash).showChannels(nil)
			puts the_channels
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
	def ayadnStarredPosts(name)
		puts $status.starsUser(name)
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
	def ayadnPostInfos(action, postID)
		puts $status.infosPost(postID)
	    puts @view.new(@api.getPostInfos(action, postID)).showPostInfos(postID, isMine = false)
	end

	def ayadnSavePost(postID)
		@progress_indicator = false
		name = postID.to_s
		unless Dir.exists?$tools.ayadn_configuration[:posts_path]
			puts "Creating posts directory in ".green + "#{$tools.ayadn_configuration[:data_path]}...".brown
			FileUtils.mkdir_p $tools.ayadn_configuration[:posts_path]
		end
		file = "/#{name}.post"
		fileURL = $tools.ayadn_configuration[:posts_path] + file
		if File.exists?(fileURL)
			abort("\nYou already saved this post.\n\n".red)
		end
		puts "\nLoading post ".green + "#{postID}".brown
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
 	def ayadn_download_files(target)
		with_url = false
		$files.makedir($tools.ayadn_configuration[:files_path])
		if target.split(",").length == 1
 			view, file_url, file_name = @view.new(@api.getSingleFile(target)).showFileInfo(with_url)
 			puts "\nDownloading file ".green + target.to_s.brown
 			puts view
 			$files.download_file(file_url, "#{file_name}", @token)
 		else
 			@hash = @api.getMultipleFiles(target)
 			@hash['data'].each do |unique_file|
	 			view, file_url, file_name = @view.new(nil).buildFileInfo(unique_file, with_url)
	 			unique_file_id = unique_file['id']
	 			puts "\nDownloading file ".green + unique_file_id.to_s.brown
	 			puts view
	 			$files.download_file(file_url, "#{unique_file_id}_#{file_name}", @token)
	 		end
 		end
 	end
 	def ayadn_delete_file(target)
 		puts "\nWARNING: ".red + "delete a file ONLY is you're sure it's not referenced by a post or a message.\n\n".pink
		puts "Do you wish to continue? (y/N) ".reddish
		if STDIN.getch == ("y" || "Y")
			puts "\nPlease wait...".green
			resp = $files.delete_file(target, @token)
			$tools.meta(resp['meta'])
		else
			puts "\n\nCanceled.\n\n".red
			exit
		end
 	end
 	def ayadn_upload_files(target)
 		case $tools.ayadn_configuration[:platform]   
        when $tools.winplatforms
        	puts "\nThis feature doesn't work on Windows yet. Sorry.\n\n".red
        	exit
        end
        $files.makedir($tools.ayadn_configuration[:files_path])
		uploaded_ids = []
		target.split(",").each do |file|
			puts "Uploading ".cyan + "#{File.basename(file)}".brown + "\n\n"
			begin
				resp = JSON.parse($files.uploadFiles(file, @token))
			rescue => e
				puts "\nERROR: ".red + e.inspect.red + "\n\n"
				exit
			end
			$tools.meta(resp['meta'])
			uploaded_ids.push(resp['data']['id'])
		end
		view, file_url, pagination_array = @view.new(@api.getFilesList(nil)).showFilesList(with_url, false)
		uploaded_ids.each do |id|
			view.gsub!("#{id}", "#{id}".reverse_color)
		end
		puts view
 	end
 	def ayadn_attribute_file(attribute, target)
		puts "\nChanging file attribute...".green
		if attribute == "public"
			data = {
				"public" => true
			}.to_json
		else
			data = {
				"public" => false
			}.to_json
		end
		response = @api.httpPutFile(target, data)
		resp = JSON.parse(response.body)
		meta = resp['meta']
		if meta['code'] == 200
			puts "\nDone!\n".green
			changed_file_id = resp['data']['id']
			view, file_url, pagination_array = @view.new(@api.getFilesList(nil)).showFilesList(with_url, false)
			view.gsub!("#{changed_file_id}", "#{changed_file_id}".reverse_color)
			puts view
		else
			puts "\nERROR: #{meta.inspect}\n".red
		end
 	end
end

