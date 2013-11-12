#!/usr/bin/ruby
# encoding: utf-8
# 
# App.net command-line client
# by Eric Dejonckheere
# http://alpha.app.net/ericd
# © 2013

require_relative 'Requires'
winPlatforms = ['mswin', 'mingw', 'mingw_18', 'mingw_19', 'mingw_20', 'mingw32']
case Gem::Platform.local.os
when *winPlatforms
	require 'win32console'
end

puts "\n\nAYADN".red + " - " + "App.net command-line client\n".brown

option1 = ARGV[0]
option2 = ARGV[1]

warnings = ErrorWarning.new
status = ClientStatus.new

case
when !option1, option1 == "flux", option1 == "f", option1 == "stream"

	puts status.getUnified()
	client = AyaDN::AppdotnetUnified.new(@token)
	puts client.getText()

when option1 == "global", option1 == "g"

	puts status.getGlobal()
	client = AyaDN::AppdotnetGlobal.new(@token)
	puts client.getText()

when option1 == "trending", option1 == "checkins", option1 == "conversations"

	#todo: puts status.whichExplore(option1)
	client = AyaDN::AppdotnetExplore.new(@token)
	puts client.getText(option1)

when option1 == "infos", option1 == "i"

	if option2 =~ /^@/ or option2 == "me"
		puts status.infosUser(option2)
		client = AyaDN::AppdotnetUserInfo.new(@token)
		puts client.getUserInfo(option2)
	elsif option2.is_integer?
		puts status.getDetails()
		client = AyaDN::AppdotnetPostInfo.new(@token)
		puts client.getPostInfo(option2)
	else
		puts warnings.errorInfos(option2)
	end

when option1 == "posts", option1 == "p"

	if option2 =~ /^@/
		puts status.postsUser(option2)
	 	client = AyaDN::AppdotnetUserPosts.new(@token)
	 	puts client.getUserPosts(option2)
	 else
	 	puts warnings.errorUsername(option2)
	 end

when option1 == "mentions", option1 == "m"

	if option2 =~ /^@/
		puts status.mentionsUser(option2)
	 	client = AyaDN::AppdotnetUserMentions.new(@token)
	 	puts client.getUserMentions(option2)
 	else
 		puts warnings.errorUsername(option2)
 	end

when option1 == "starred", option1 == "s"

	if option2 =~ /^@/
 		puts status.starsUser(option2)
		client = AyaDN::AppdotnetStarredPosts.new(@token)
		puts client.getStarredPosts(option2)
	elsif option2.is_integer?
		puts status.starsPost(option2)
		client = AyaDN::AppdotnetWhoStarred.new(@token)
		puts client.getStarredByUsers(option2)
	else
		puts warnings.errorUsername(option2)
	end

when option1 == "reposted"

	if option2.is_integer?
		# status
		client = AyaDN::AppdotnetWhoReposted.new(@token)
		puts client.getRepostedByUsers(option2)
	else
		# err not postID
	end

when option1 == "tag", option1 == "t"

	client = AyaDN::AppdotnetHashtagSearch.new
	option2_new = option2.dup
	if option2_new =~ /^#/
		option2_new[0] = ""
	end
	puts status.getHashtags(option2_new)
	puts client.getTaggedPosts(option2_new)

when option1 == "write", option1 == "w"

	if option2 != nil
		puts status.sendPost()
		client = AyaDN::AppdotnetSendPost.new(@token)
		puts client.createPost(option2, nil)
	else
		puts status.writePost()
		client = AyaDN::AppdotnetSendPost.new(@token)
		puts client.composePost()
	end


when option1 == "reply", option1 == "r"

	if option2.is_integer?
		# option2 is the ID of the post
		# compose window
		#puts status.writeReply(option2)
		client = AyaDN::AppdotnetSendReply.new(@token)
		puts client.replyPost(option2)
		exit
	else
		puts warnings.errorReply(option2)
		exit
	end

when option1 == "star"

	if option2.is_integer?
		client = AyaDN::AppdotnetStarPost.new(@token)
		client.starPost(option2)
		puts "\nYou just starred post ".green + " #{option2}".brown + ".\n\n".green
		exit
	else
		puts warnings.errorPostID(option2)
		exit
	end

when option1 == "unstar"

	if option2.is_integer?
		client = AyaDN::AppdotnetStarPost.new(@token)
		client.unstarPost(option2)
		puts "\nYou just unstarred post ".green + "#{option2}".brown + ".\n\n".green
		exit
	else
		puts warnings.errorPostID(option2)
		exit
	end

when option1 == "follow"

	if option2 =~ /^@/
		client = AyaDN::AppdotnetFollow.new(@token)
		client.followUser(option2)
		puts "\nYou just followed user ".green + "#{option2}".brown + "\n\n"
	else
		puts warnings.errorUsername(option2)
	end

when option1 == "unfollow"

	if option2 =~ /^@/
		client = AyaDN::AppdotnetFollow.new(@token)
		client.unFollowUser(option2)
		puts "\nYou just unfollowed user ".green + "#{option2}".brown + "\n\n"
	else
		puts warnings.errorUsername(option2)
	end


when option1 == "convo", option1 == "c"

	if option2.is_integer?
		puts status.getPostReplies(option2)
		client = AyaDN::AppdotnetPostReplies.new(@token)
		puts client.getPostReplies(option2)
	else
		puts warnings.errorPostID(option2)
	end

when option1 == "help", option1 == "aide", option1 == "h"

	puts @help

else

	if option1 != nil
		option = ARGV
		bad_option = option.join(" ")
		puts warnings.syntaxError(bad_option)
	end
	puts warnings.globalError()
	puts @help

end





