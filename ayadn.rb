#!/usr/bin/ruby
# encoding: utf-8
# App.net command-line client
# by Eric Dejonckheere
# http://alpha.app.net/ericd
# © 2013

require_relative 'requires'

puts "\nAYADN".red + " - " + "App.net command-line client\n".brown

run = AyaDN.new(@token)
status = AyaDN::ClientStatus.new
tools = AyaDN::Tools.new

arg1, arg2, arg3, arg4 = ARGV[0], ARGV[1], ARGV[2], ARGV[3]

case arg1

when "authorize", "login"
	run.ayadnAuthorize

when "scroll"
	run.ayadnScroll(arg2, arg3)

when nil, "flux", "stream", "uni", "unified"
	run.ayadnUnified

when "global", "g"
	run.ayadnGlobal()

when "trending", "conversations", "checkins", "photos"
	run.ayadnExplore(arg1)

when "mentions", "m"
	(arg2 =~ /^@/ || arg2 == "me") ? run.ayadnUserMentions(arg2) : (puts status.errorUserID(arg2))

when "posts", "p"
	(arg2 =~ /^@/ || arg2 == "me") ? run.ayadnUserPosts(arg2) : (puts status.errorUserID(arg2))

when "starred"
	if arg2 =~ /^@/ || arg2 == "me"
		run.ayadnStarredPosts(arg2)
	elsif arg2.is_integer?
		run.ayadnWhoStarred(arg2)
	else
		puts status.errorUserID(arg2)
	end

when "reposted"
	arg2.is_integer? ? run.ayadnWhoReposted(arg2) : (puts status.errorPostID(arg2))

when "infos", "i"
	if arg2 =~ /^@/ || arg2 == "me"
		run.ayadnUserInfos(arg2)
	elsif arg2.is_integer?
		run.ayadnPostInfos("call", arg2)
	else
		puts status.errorInfos(arg2)
	end

when "convo", "c"
	arg2.is_integer? ? run.ayadnConversation(arg2) : (puts status.errorPostID(arg2))

when "tag", "t"
	theTag = arg2.dup
	theTag[0] = "" if theTag =~ /^#/
	run.ayadnHashtags(theTag)

when "delete"
	if arg2.is_integer?
		puts "\nAre you sure you want to delete post ".green + "#{arg2}? ".brown + "(n/y) ".green 
		input = STDIN.getch
		(input == "y" || input == "Y") ? run.ayadnDeletePost(arg2) : (puts "\nCanceled.\n\n".red)
	else
		puts status.errorPostID(arg2)
	end

when "save"
	arg2.is_integer? ? run.ayadnSavePost(arg2) : (puts status.errorPostID(arg2))

when "load"
	arg2.is_integer? ? run.ayadnPostInfos("load", arg2) : (puts status.errorPostID(arg2))

when "backup"
	if arg2 == "followings"
		(arg3 =~ /^@/ || arg3 == "me") ? run.ayadnSaveList("followings", arg3) : (puts "syntax error")
	elsif arg2 == "followers"
		(arg3 =~ /^@/ || arg3 == "me") ? run.ayadnSaveList("followers", arg3) : (puts "syntax error")
	elsif arg2 == "muted"
		run.ayadnSaveList("muted", "me")
	end

when "list"
	if arg2 == "followings"
		(arg3 =~ /^@/ || arg3 == "me") ? run.ayadnShowList("followings", arg3) : (puts "syntax error")
	elsif arg2 == "followers"
		(arg3 =~ /^@/ || arg3 == "me") ? run.ayadnShowList("followers", arg3) : (puts "syntax error")
	elsif arg2 == "muted"
		run.ayadnShowList("muted", "me")
	else
		puts "\nSyntax error\n"
	end

when "star"
	arg2.is_integer? ? run.ayadnStarringPost("star", arg2) : (puts status.errorPostID(arg2))

when "unstar"
	arg2.is_integer? ? run.ayadnStarringPost("unstar", arg2) : (puts status.errorPostID(arg2))

when "repost"
	arg2.is_integer? ? run.ayadnReposting("repost", arg2) : (puts status.errorPostID(arg2))

when "unrepost"
	arg2.is_integer? ? run.ayadnReposting("unrepost", arg2) : (puts status.errorPostID(arg2))

when "follow"
	arg2 =~ /^@/ ? run.ayadnFollowing("follow", arg2) : (puts status.errorUserID(arg2))

when "unfollow"
	arg2 =~ /^@/ ? run.ayadnFollowing("unfollow", arg2) : (puts status.errorUserID(arg2))

when "mute"
	arg2 =~ /^@/ ? run.ayadnMuting("mute", arg2) : (puts status.errorUserID(arg2))

when "unmute"
	arg2 =~ /^@/ ? run.ayadnMuting("unmute", arg2) : (puts status.errorUserID(arg2))

when "pm"
	if arg3 != nil
		# ayadn pm @ericd "hello!"
		run.ayadnSendMessage(arg2, arg3)
	else
		run.ayadnComposeMessage(arg2)
	end

when "messages"
	# arg2 is integer -> display channel stream
	# arg2 == "list" -> get a list of your previously used channels
	# else we get channel ID from @username (if already accessed)
	run.ayadnGetMessages(arg2)

when "write", "w"
	arg2 != nil ? run.ayadnSendPost(arg2, nil) : run.ayadnComposePost

when "reply", "r"
	if arg2 != nil
		arg2.is_integer? ? run.ayadnReply(arg2) : (puts status.errorPostID(arg2))
	else
		puts status.errorNoID
	end

when "search", "s"
	arg2 != nil ? run.ayadnSearch(arg2) : (puts "\nsyntax error\n")

when "help", "h"
	puts tools.helpScreen()

when "debug"
	if arg2 == nil
		run.ayadnDebugStream
	elsif arg2.is_integer?
		run.ayadnDebugPost(arg2)
	end

when "reset"
	if arg2 == "pagination"
		run.ayadnReset("pagination", arg3, arg4)
	elsif arg2 == nil
		run.ayadnReset("pagination", nil, nil)
	end

else
	# if not any known argument
	option = ARGV
	bad_option = option.join(" ")
	puts "\nSyntax error: ".red + "#{bad_option} ".brown + "is not a valid option.\n\n".red
	puts tools.helpScreen()

end

