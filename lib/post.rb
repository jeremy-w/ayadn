#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def ayadnSendPost(text, reply_to = nil)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendPost
		blob = JSON.parse(@api.httpSend(text, reply_to))
		@hash = blob['data']
		my_post_id = @hash['id']
		puts @view.new(nil).buildSimplePostInfo(@hash)
		puts $status.postSent
		# show end of the stream after posting
		if (reply_to == nil || reply_to.empty? )
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
	def ayadnComposePost(reply_to = "", mentions_list = "", my_username = "")
		puts $status.writePost
		char_count = $tools.ayadn_configuration[:post_max_length] - mentions_list.length
		# be careful to not color escape mentions_list or text
		text = mentions_list
		if !mentions_list.empty?
			text += " "
			char_count -= 1
		end
		print "\n#{text}"
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorPostNotSent)
		end
		post_text = text + input_text
		total_length = char_count - $tools.getMarkdownText(post_text.dup).length
		real_length = $tools.ayadn_configuration[:post_max_length] + total_length.abs
		if total_length > 0
			ayadnSendPost(post_text, reply_to)
		else
			abort($status.errorPostTooLong(real_length, real_length - $tools.ayadn_configuration[:post_max_length]))
		end
	end
	def ayadnReply(postID)
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
			my_username = @api.getUserName("me")
		else
			my_username = $tools.config['identity']['prefix']
		end
		#my_handle = "@" + my_username
		replying_to_handle = "@" + replying_to_this_username
		new_content = Array.new
		# if I'm not answering myself, add the @username of the "replyee"
		new_content.push(replying_to_handle) if replying_to_this_username != my_username 
		post_mentions_array.each do |item|
			# if I'm in the post's mentions, erase me, else insert the mention
			if item != my_username
				new_content.push("@" + item)
			end
		end
		ayadnComposePost(postID, new_content.join(" "))
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