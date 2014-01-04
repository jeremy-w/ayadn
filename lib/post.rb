#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def ayadn_compose_post
		puts $status.writePost + "\n"
		char_count = $tools.ayadn_configuration[:post_max_length]
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorPostNotSent)
		end
		real_text_length = $tools.getMarkdownText(input_text.dup).length
		remaining_text_length = char_count - real_text_length
		if remaining_text_length >= 0
			ayadnSendPost(input_text, nil)
		else
			abort($status.errorPostTooLong(real_text_length, remaining_text_length.abs))
		end
	end
	def ayadnSendPost(text, reply_to = nil)
		abort($status.emptyPost) if (text == nil)
		puts $status.sendPost
		blob = JSON.parse(@api.httpSend(text, reply_to))
		@hash = blob['data']
		my_post_id = @hash['id']
		puts @view.new(nil).buildSimplePostInfo(@hash)
		puts $status.postSent
		# save post
		if $tools.config['files']['auto_save_sent_posts']
			fileURL = $tools.ayadn_configuration[:posts_path] + "/#{my_post_id}.post"
			f = File.new(fileURL, "w")
			f.puts(@hash)
			f.close
		end
		# show end of the stream after posting
		if (reply_to == nil || reply_to.empty?)
			#@progress_indicator = false
			@hash = @api.getSimpleUnified
			stream, last_page_id = completeStream
			stream.sub!(/#{my_post_id}/, my_post_id.to_s.green.reverse_color)
			displayStream(stream)
		else
			#@progress_indicator = true
			#@reply_to = reply_to
			@hash = @api.getPostReplies(reply_to)
			# t1 = Thread.new{@api.getPostReplies(@reply_to)}
			# t2 = Thread.new{@api.getSimpleUnified}
			# t1.join
			# t2.join
			# hash1 = t1.value
			# hash2 = t2.value
			# first = hash2['data'].last # because adnData.reverse in API
			# first_id = first['id']
			# if first_id.to_i > reply_to.to_i
			# 	puts @view.new(nil).buildSimplePost(hash1['data'].last)
			# end
			#@hash = hash1.merge(hash2)
			stream, last_page_id = completeStream
			stream.sub!(/#{reply_to}/, reply_to.to_s.red.reverse_color)
			stream.sub!(/#{my_post_id}/, my_post_id.to_s.green.reverse_color)
			displayStream(stream)
		end
	end
	def ayadn_reply(postID)
		@progress_indicator = false
		puts $status.replyingToPost(postID)
		post_mentions_array, replying_to_this_username, is_repost = @api.getPostMentions(postID) 
		if is_repost != nil
			puts $status.errorIsRepost(postID)
			postID = is_repost['id']
			puts $status.redirectingToOriginal(postID)
			post_mentions_array, replying_to_this_username, is_repost = @api.getPostMentions(postID) 
		end
		if $tools.config['identity']['prefix'] == "me"
			me_saved = $files.users_read("me")
			me_saved ? (my_username = me_saved) : (my_username = @api.getUserName("me"))
		else
			my_username = $tools.config['identity']['prefix']
		end
		#my_handle = "@" + my_username
		replying_to_handle = "@" + replying_to_this_username
		new_content = Array.new
		# if I'm not answering myself, add the @username of the "replyee"
		new_content.push(replying_to_handle) if replying_to_this_username != my_username 
		post_mentions_array.each do |item|
			new_content.push("@" + item) if item != my_username
		end
		if new_content.length > 1
			all_mentions = new_content.dup
			leading_mention = all_mentions.first
			all_mentions.shift
			puts "\nThe leading mention (".green + leading_mention.red + ") has been put at the beginning of your post.\nThe rest of the mentions (".green + all_mentions.join(", ").red + ") will be added automatically at the end.".green
		end
		ayadn_compose_reply(postID, new_content)
	end
	def ayadn_compose_reply(reply_to, mentions_list = "")
		puts $status.writePost
		all_mentions = mentions_list.dup
		char_count = $tools.ayadn_configuration[:post_max_length]
		leading_mention = all_mentions.first
		mentions_list.shift
		mentions_list = mentions_list.join(" ")
		if leading_mention != nil
			text = leading_mention + " "
			char_count -= 1
		else
			text = ""
		end
		print "\n#{text}"
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorPostNotSent)
		end
		if leading_mention != nil
			post_text = text + input_text + " " + mentions_list
			real_text_length = $tools.getMarkdownText(post_text.dup).length
		else
			post_text = input_text
			real_text_length = $tools.getMarkdownText(post_text.dup).length
		end
		remaining_text_length = char_count - real_text_length
		if remaining_text_length >= 0
			ayadnSendPost(post_text, reply_to)
		else
			abort($status.errorPostTooLong(real_length, real_length - $tools.ayadn_configuration[:post_max_length]))
		end
	end


	def ayadnComposeMessage(target)
		puts $status.writeMessage
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorMessageNotSent)
		end
		real_length = $tools.getMarkdownText(input_text.dup).length
		if real_length < $tools.ayadn_configuration[:message_max_length]
			ayadnSendMessage(target, input_text)
		else
			abort($status.errorMessageTooLong(real_length, real_length - $tools.ayadn_configuration[:message_max_length]))
		end
	end
	def ayadnSendMessage(target, text)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendMessage
		blob = JSON.parse(@api.httpSendMessage(target, text))
		@hash = blob['data']
		private_message_channel_ID = @hash['channel_id']
		#private_message_thread_ID = @hash['thread_id']
		$files.makedir($tools.ayadn_configuration[:messages_path])
		puts "Channel ID: ".cyan + private_message_channel_ID.brown + " Message ID: ".cyan + @hash['id'].brown + "\n\n"
		puts $status.postSent
		$files.save_channel_id(private_message_channel_ID, target)
		# save message
		if $tools.config['files']['auto_save_sent_messages']
			fileURL = $tools.ayadn_configuration[:messages_path] + "/#{target}-#{@hash['id']}.post"
			f = File.new(fileURL, "w")
			f.puts(@hash)
			f.close
		end
	end

	def ayadnComposeMessageToChannel(target)
		puts $status.writeMessage
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorMessageNotSent)
		end
		real_length = $tools.getMarkdownText(input_text.dup).length
		if real_length < $tools.ayadn_configuration[:message_max_length]
			ayadnSendMessageToChannel(target, input_text)
		else
			abort($status.errorMessageTooLong(real_length, real_length - $tools.ayadn_configuration[:message_max_length]))
		end
	end
	def ayadnSendMessageToChannel(target, text)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendMessage
		blob = JSON.parse(@api.httpSendMessageToChannel(target, text))
		@hash = blob['data']
		private_channel_ID = @hash['channel_id']
		#private_thread_ID = @hash['thread_id']
		$files.makedir($tools.ayadn_configuration[:messages_path])
		puts "Channel ID: ".cyan + private_channel_ID.brown + " Message ID: ".cyan + @hash['id'].brown + "\n\n"
		puts $status.postSent
		$files.save_channel_id(private_message_channel_ID, target)
	end
end