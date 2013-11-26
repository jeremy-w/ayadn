#!/usr/bin/ruby
# encoding: utf-8
# App.net command-line client
# by Eric Dejonckheere
# http://alpha.app.net/ericd
# © 2013

require_relative 'requires'

puts "\nAYADN".red + " - " + "App.net command-line client\n".brown

run = AyaDN.new(@token)
status = ClientStatus.new

arg1, arg2, arg3, arg4 = ARGV[0], ARGV[1], ARGV[2], ARGV[3]

case arg1
when "scroll"
	run.ayadnScroll(arg2, arg3)
	exit
when nil, "flux", "stream", "uni", "unified"
	run.ayadnUnified
	exit
when "global", "g"
	run.ayadnGlobal()
	exit
when "trending", "conversations", "checkins", "photos"
	run.ayadnExplore(arg1)
	exit
when "mentions", "m"
	if arg2 =~ /^@/ or arg2 == "me"
		run.ayadnUserMentions(arg2)
	else
		puts status.errorUserID(arg2)
	end
	exit
when "posts", "p"
	if arg2 =~ /^@/ or arg2 == "me"
		run.ayadnUserPosts(arg2)
	else
		puts status.errorUserID(arg2)
	end
	exit
when "starred"
	if arg2 =~ /^@/ or arg2 == "me"
		# get a user's starred posts
		run.ayadnStarredPosts(arg2)
	elsif arg2.is_integer?
		# get who starred a post
		run.ayadnWhoStarred(arg2)
	else
		puts status.errorUserID(arg2)
	end
	exit
when "reposted"
	if arg2.is_integer?
		run.ayadnWhoReposted(arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "infos", "i"
	if arg2 =~ /^@/ or arg2 == "me"
		# get user infos
		run.ayadnUserInfos(arg2)
	elsif arg2.is_integer?
		# get post infos
		run.ayadnPostInfos("call", arg2)
	else
		puts status.errorInfos(arg2)
	end
	exit
when "convo", "c"
	if arg2.is_integer?
		run.ayadnConversation(arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "tag", "t"
	theTag = arg2.dup
	if theTag =~ /^#/
		theTag[0] = ""
	end
	run.ayadnHashtags(theTag)
	exit
when "delete"
	if arg2.is_integer?
		puts "\nAre you sure you want to delete post ".green + "#{arg2}? ".brown + "(n/y) ".green 
		input = STDIN.getch
		if input == "y" or input == "Y"
			run.ayadnDeletePost(arg2)
		else
			puts "\nCanceled.\n\n".red
		end
	else
		puts status.errorPostID(arg2)
	end
	exit
when "save"
	if arg2.is_integer?
		run.ayadnSavePost(arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "load"
	if arg2.is_integer?
		run.ayadnPostInfos("load", arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "backup"
	if arg2 == "followings"
		if arg3 =~ /^@/ or arg3 == "me"
			run.ayadnSaveList("followings", arg3)
		else
			puts "syntax error"
		end
	elsif arg2 == "followers"
		if arg3 =~ /^@/ or arg3 == "me"
			run.ayadnSaveList("followers", arg3)
		else
			puts "syntax error"
		end
	elsif arg2 == "muted"
			run.ayadnSaveList("muted", "me")
	end
	exit
when "list"
	if arg2 == "muted"
		puts run.ayadnShowList("muted", "me")
	end
	if arg2 == "followings"
		if arg3 =~ /^@/ or arg3 == "me"
			run.ayadnShowList("followings", arg3)
		else
			puts "syntax error"
		end
	end
	if arg2 == "followers"
		if arg3 =~ /^@/ or arg3 == "me"
			run.ayadnShowList("followers", arg3)
		else
			puts "syntax error"
		end
	end
	exit
when "star"
	if arg2.is_integer?
		run.ayadnStarringPost("star", arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "unstar"
	if arg2.is_integer?
		run.ayadnStarringPost("unstar", arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "repost"
	if arg2.is_integer?
		run.ayadnReposting("repost", arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "unrepost"
	if arg2.is_integer?
		run.ayadnReposting("unrepost", arg2)
	else
		puts status.errorPostID(arg2)
	end
	exit
when "follow"
	if arg2 =~ /^@/
		run.ayadnFollowing("follow", arg2)
	else
		puts status.errorUserID(arg2)
	end
	exit
when "unfollow"
	if arg2 =~ /^@/
		run.ayadnFollowing("unfollow", arg2)
	else
		puts status.errorUserID(arg2)
	end
	exit
when "mute"
	if arg2 =~ /^@/
		run.ayadnMuting("mute", arg2)
	else
		puts status.errorUserID(arg2)
	end
	exit
when "unmute"
	if arg2 =~ /^@/
		run.ayadnMuting("unmute", arg2)
	else
		puts status.errorUserID(arg2)
	end
	exit
	
when "pm"
	if arg3 != nil
		# ayadn pm @ericd "hello!"
		run.ayadnSendMessage(arg2, arg3)
	else
		run.ayadnComposeMessage(arg2)
	end
	exit

when "messages"
	# arg2 -> channel ID
	run.ayadnGetMessages(arg2)
	exit

when "write", "w"
	if arg2 != nil
		run.ayadnSendPost(arg2, nil)
	else
		run.ayadnComposePost()
	end
	exit
when "reply", "r"
	if arg2 != nil
		if arg2.is_integer?
			run.ayadnReply(arg2)
		else
			puts status.errorPostID(arg2)
		end
	else
		puts status.errorNoID
	end
	exit
when "search", "s"
	if arg2 != nil
		run.ayadnSearch(arg2)
	else
		puts "\nsyntax error\n"
	end
	exit
when "help", "h"
	puts AyaDN::Tools.new.helpScreen()
	exit
when "debug"
	if arg2 == nil
		run.ayadnDebugStream
	elsif arg2.is_integer?
		run.ayadnDebugPost(arg2)
	end
	exit
when "reset"
	if arg2 == "pagination"
		run.ayadnReset("pagination", arg3, arg4)
	elsif arg2 == nil
		run.ayadnReset("pagination", nil, nil)
	end
	exit
end

# if not any known argument
option = ARGV
bad_option = option.join(" ")
puts "\nSyntax error: ".red + "#{bad_option} ".brown + "is not a valid option.\n\n".red
puts AyaDN::Tools.new.helpScreen()