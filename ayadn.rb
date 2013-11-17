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

arg1, arg2, arg3 = ARGV[0], ARGV[1], ARGV[2]

case
when !arg1, arg1 == "flux", arg1 == "stream", arg1 == "uni", arg1 == "unified"
	# get unified
	run.ayadnUnified

when arg1 == "global", arg1 == "g"
	# get global
	run.ayadnGlobal()

when arg1 == "trending", arg1 == "conversations", arg1 == "checkins"
	# get explore streams
	run.ayadnExplore(arg1)

when arg1 == "mentions", arg1 == "m"
	# get user mentions
	if arg2 =~ /^@/
		run.ayadnUserMentions(arg2)
	else
		puts status.errorUserID(arg2)
	end

when arg1 == "posts", arg1 == "p"
	# get user posts
	if arg2 =~ /^@/
		run.ayadnUserPosts(arg2)
	else
		puts status.errorUserID(arg2)
	end

when arg1 == "starred"
	if arg2 =~ /^@/
		# get a user's starred posts
		run.ayadnStarredPosts(arg2)
	elsif arg2.is_integer?
		# get who starred a post
		run.ayadnWhoStarred(arg2)
	else
		puts status.errorUserID(arg2)
	end

when arg1 == "reposted"
	if arg2.is_integer?
		# get who reposted a post
		run.ayadnWhoReposted(arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "infos", arg1 == "i"
	if arg2 =~ /^@/
		# get user infos
		run.ayadnUserInfos(arg2)
	elsif arg2.is_integer?
		# get post infos
		run.ayadnPostInfos("call", arg2)
	else
		puts status.errorInfos(arg2)
	end


when arg1 == "convo", arg1 == "c"
	# read the conversation around a post
	if arg2.is_integer?
		run.ayadnConversation(arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "tag", arg1 == "t"
	# get hashtags
	theTag = arg2.dup
	if theTag =~ /^#/
		theTag[0] = ""
	end
	run.ayadnHashtags(theTag)

when arg1 == "delete"
	# delete a post
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

when arg1 == "save"
	if arg2.is_integer?
		# save a post
		run.ayadnSavePost(arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "load"
	if arg2.is_integer?
		# load a post
		run.ayadnPostInfos("load", arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "star"
	if arg2.is_integer?
		# star a post
		run.ayadnStarringPost("star", arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "unstar"
	if arg2.is_integer?
		# unstar a post
		run.ayadnStarringPost("unstar", arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "repost"
	if arg2.is_integer?
		# repost
		run.ayadnReposting("repost", arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "unrepost"
	if arg2.is_integer?
		# unrepost
		run.ayadnReposting("unrepost", arg2)
	else
		puts status.errorPostID(arg2)
	end

when arg1 == "follow"
	if arg2 =~ /^@/
		# follow a user
		run.ayadnFollowing("follow", arg2)
	else
		puts status.errorUserID(arg2)
	end

when arg1 == "unfollow"
	if arg2 =~ /^@/
		# unfollow a user
		run.ayadnFollowing("unfollow", arg2)
	else
		puts status.errorUserID(arg2)
	end


when arg1 == "write", arg1 == "w"
	if arg2 != nil
		# write
		run.ayadnSendPost(arg2, nil)
	else
		# compose
		run.ayadnComposePost()
	end

when arg1 == "reply", arg1 == "r"
	if arg2 != nil
		if arg2.is_integer?
			# reply to postID
			run.ayadnReply(arg2)
		else
			puts status.errorPostID(arg2)
		end
	else
		puts status.errorNoID
	end

when arg1 == "help", arg1 == "h"
	puts AyaDN::Tools.new.helpScreen()

when arg1 != nil
	option = ARGV
	bad_option = option.join(" ")
	puts "\nSyntax error: ".red + "#{bad_option} ".brown + "is not a valid option.\n\n".red
	puts AyaDN::Tools.new.helpScreen()

end
