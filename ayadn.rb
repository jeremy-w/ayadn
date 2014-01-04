#!/usr/bin/env ruby
# encoding: utf-8
# App.net command-line client
# by Eric Dejonckheere
# http://alpha.app.net/ericd
# © 2013

require_relative 'requires'

puts "\n\nAYADN".red + " - " + "App.net command-line client\n".brown

$status = AyaDN::ClientStatus.new
$tools = AyaDN::Tools.new
$files = AyaDN::Files.new

token = $files.auth_read
if token != nil
	client = AyaDN.new(token)
	client.configAPI
else
	puts $status.errorNotAuthorized
	AyaDN.new(nil).ayadnAuthorize(nil)
	exit
end

arg1, arg2, arg3, arg4 = ARGV[0], ARGV[1], ARGV[2], ARGV[3]

case arg1

when "scroll"
	client.ayadnScroll(arg2, arg3)

when nil
	client.ayadnUnified(nil)

when "unified"
	client.ayadnUnified(arg2)

when "write", "w"
	arg2 != nil ? client.ayadnSendPost(arg2, nil) : client.ayadn_compose_post

when "reply", "r"
	if arg2 != nil
		arg2.is_integer? ? client.ayadn_reply(arg2) : (puts $status.errorPostID(arg2))
	else
		puts $status.errorNoID
	end

when "global", "g"
	client.ayadnGlobal(arg2)

when "mentions", "m"
	(arg2 =~ /^@/ || arg2 == "me") ? client.ayadnUserMentions(arg2, arg3) : (puts $status.errorUserID(arg2))

when "posts", "p"
	(arg2 =~ /^@/ || arg2 == "me") ? client.ayadnUserPosts(arg2, arg3) : (puts $status.errorUserID(arg2))

when "trending", "conversations", "checkins", "photos"
	client.ayadnExplore(arg1, arg2)

when "starred"
	if arg2 =~ /^@/ || arg2 == "me"
		client.ayadnStarredPosts(arg2, arg3)
	elsif arg2.is_integer?
		client.ayadnWhoStarred(arg2)
	else
		puts $status.errorUserID(arg2)
	end

when "reposted"
	arg2.is_integer? ? client.ayadnWhoReposted(arg2) : (puts $status.errorPostID(arg2))

when "infos", "i"
	if arg2 =~ /^@/ || arg2 == "me"
		client.ayadnUserInfos(arg2)
	elsif arg2.is_integer?
		client.ayadnPostInfos(arg2)
	else
		puts $status.errorInfos(arg2)
	end

when "convo", "c"
	arg2.is_integer? ? client.ayadnConversation(arg2) : (puts $status.errorPostID(arg2))

when "tag", "t"
	theTag = arg2.dup
	theTag[0] = "" if theTag =~ /^#/
	client.ayadnHashtags(theTag)

when "delete"
	if arg2.is_integer?
		puts "\nAre you sure you want to delete post ".green + "#{arg2}? ".brown + "(n/y) ".green 
		input = STDIN.getch
		(input == "y" || input == "Y") ? client.ayadnDeletePost(arg2) : (puts "\nCanceled.\n\n".red)
	else
		puts $status.errorPostID(arg2)
	end

when "save"
	arg2.is_integer? ? client.ayadnSavePost(arg2) : (puts $status.errorPostID(arg2))

when "load"
	arg2.is_integer? ? client.ayadnLoadPost(arg2) : (puts $status.errorPostID(arg2))

when "backup"
	if arg2 == "followings"
		(arg3 =~ /^@/ || arg3 == "me") ? client.ayadnSaveList("followings", arg3) : (puts $status.errorSyntax)
	elsif arg2 == "followers"
		(arg3 =~ /^@/ || arg3 == "me") ? client.ayadnSaveList("followers", arg3) : (puts $status.errorSyntax)
	elsif arg2 == "muted"
		client.ayadnSaveList("muted", "me")
	end

when "list"
	case arg2
	when "followings"
		(arg3 =~ /^@/ || arg3 == "me") ? client.ayadnShowList("followings", arg3) : (puts $status.errorSyntax)
	when "followers"
		(arg3 =~ /^@/ || arg3 == "me") ? client.ayadnShowList("followers", arg3) : (puts $status.errorSyntax)
	when "muted"
		client.ayadnShowList("muted", "me")
	when "files"
		client.ayadn_list_files(arg3)
	when "options","config"
		client.ayadn_show_options
	when "channels"
		client.get_loaded_channels
		client.ayadn_get_channels
	else
		puts $status.errorSyntax
	end

when "star"
	arg2.is_integer? ? client.ayadnStarringPost("star", arg2) : (puts $status.errorPostID(arg2))

when "unstar"
	arg2.is_integer? ? client.ayadnStarringPost("unstar", arg2) : (puts $status.errorPostID(arg2))

when "repost"
	arg2.is_integer? ? client.ayadnReposting("repost", arg2) : (puts $status.errorPostID(arg2))

when "unrepost"
	arg2.is_integer? ? client.ayadnReposting("unrepost", arg2) : (puts $status.errorPostID(arg2))

when "follow"
	arg2 =~ /^@/ ? client.ayadnFollowing("follow", arg2) : (puts $status.errorUserID(arg2))

when "unfollow"
	arg2 =~ /^@/ ? client.ayadnFollowing("unfollow", arg2) : (puts $status.errorUserID(arg2))

when "mute"
	arg2 =~ /^@/ ? client.ayadnMuting("mute", arg2) : (puts $status.errorUserID(arg2))

when "unmute"
	arg2 =~ /^@/ ? client.ayadnMuting("unmute", arg2) : (puts $status.errorUserID(arg2))

when "pm", "send"
	if !arg2.is_integer?
		if arg3 != nil
			# ayadn pm @ericd "hello!"
			client.ayadnSendMessage(arg2, arg3)
		else
			client.ayadnComposeMessage(arg2)
		end
	else
		if arg3 != nil
			# ayadn send 12345 "hello, channel!"
			client.ayadnSendMessageToChannel(arg2, arg3)
		else
			client.ayadnComposeMessageToChannel(arg2)
		end
	end

when "channels"
	client.get_loaded_channels
	client.ayadn_get_channels

when "messages"
	# arg2 is integer -> display channel stream
	# arg3 == nil = with pagination, arg3 == "all" = no pagination
	client.ayadnGetMessages(arg2, arg3)

when "search", "s"
	arg2 != nil ? client.ayadnSearch(arg2) : (puts $status.errorSyntax)

when "inter", "interactions", "events"
	client.ayadnInteractions

when "help", "h"
	puts $tools.helpScreen

when "commands"
	puts $tools.list_of_commands

when "webhelp"
	puts $tools.helpScreen
	begin 
		$tools.startBrowser("https://github.com/ericdke/ayadn#ayadn")
	rescue
		puts "\nFailed to start a browser automatically. Please visit ".cyan + "https://github.com/ericdke/ayadn#ayadn".magenta
	end

when "options"
	client.ayadn_show_options

when "debug"
	if arg2 == nil
		client.ayadnDebugStream
	elsif arg2 =~ /^@/
		client.ayadnDebugUser(arg2)
	elsif arg3.is_integer?
		if arg2 == "post"
			client.ayadnDebugPost(arg3)
		elsif arg2 == "message"
			# channel_id, message_id
			client.ayadnDebugMessage(arg3, arg4)
		end
	end

when "skip-source"
	if arg2 == "add"
		client.ayadn_skip_add("sources", arg3)
	elsif arg2 == "remove"
		client.ayadn_skip_remove("sources", arg3)
	else
		puts $status.errorSyntax
	end

when "skip-tag"
	if arg2 == "add"
		client.ayadn_skip_add("hashtags", arg3)
	elsif arg2 == "remove"
		client.ayadn_skip_remove("hashtags", arg3)
	else
		puts $status.errorSyntax
	end

when "skip-mention"
	if arg2 == "add"
		client.ayadn_skip_add("mentions", arg3)
	elsif arg2 == "remove"
		client.ayadn_skip_remove("mentions", arg3)
	else
		puts $status.errorSyntax
	end

when "reset"
	if arg2 == "pagination"
		client.ayadnReset(arg3, arg4)
	elsif arg2 == nil
		client.ayadnReset(nil, nil)
	end

# when "deactivate"
# 	# deactivate a user channel
# 	client.ayadnDeactivateChannel(arg2)

when "random"
	# just for fun :)
	api = AyaDN::API.new(token)
	puts "Fetching random posts, wait a second... (quit with CTRL+C)\n\n".green
	$tools.config['counts']['global'] = 20
	hash = api.getGlobal(nil)
	last_post = hash['data'][0]['id'].to_i
	loop do
		begin
			rnd_post_num = rand(last_post + 1)
			hash = api.getPostInfos("call", rnd_post_num)
			hash = hash['data']
			if hash['text'] == nil
				sleep 0.2
				next
			end
			puts AyaDN::View.new(nil).buildSimplePost(hash)
			sleep 2
		rescue Exception
			abort($status.stopped)
		end
	end

when "delete-message"
	client.ayadn_delete_message(arg2, arg3) #channel, message

when "download"
	client.ayadn_download_files(arg2)

when "delete-file"
	client.ayadn_delete_file(arg2)

when "upload"
	client.ayadn_upload_files(arg2)

when "private", "public"
	client.ayadn_attribute_file(arg1, arg2)

when "pin"
	client.ayadnBookmark(ARGV)

when "stream_global"
	client.ayadn_userstream

when "authorize", "login"
	AyaDN.new(nil).ayadnAuthorize("reset")

when "install"
	if arg2 == "config"
		$tools.installConfig
	else
		puts $status.errorSyntax
	end

else
	# if not any known argument
	puts $status.errorSyntax
	puts "#{ARGV.join(" ")} ".brown + "is not a valid option.\n\n".red
	puts $tools.helpScreen

end