#!/usr/bin/ruby
# App.net client
# Learning Ruby and ADN
# by Eric Dejonckheere
# © 2013

require_relative 'Requires'
winPlatforms = ['mswin', 'mingw', 'mingw_18', 'mingw_19', 'mingw_20']
case Gem::Platform.local.os
when *winPlatforms
	require 'win32console'
end

puts "\nAYADN".red
puts "App.net command-line client\n".reddish

option1 = ARGV[0]
option2 = ARGV[1]

warnings = ErrorWarning.new

case
when !option1, option1 == "flux", option1 == "f", option1 == "stream"
	puts "\nChargement du Unified Stream...\n".green
	client = AyaDN::AppdotnetUnified.new(@token)
	puts client.getText()

when option1 == "global", option1 == "g"
	puts "\nChargement du Global Stream...\n".green
	client = AyaDN::AppdotnetGlobal.new(@token)
	puts client.getText()

when option1 == "infos", option1 == "i"
	if option2 =~ /^@/
		puts "\nChargement des informations sur ".green + "#{option2}...\n".reddish
		client = AyaDN::AppdotnetUserInfo.new(@token)
		puts client.getUserInfo(option2)
	else
		puts warnings.errorUsername(option2)
	end

when option1 == "posts", option1 == "p"
	if option2 =~ /^@/
		puts "\nChargement des posts de ".green + "#{option2}...\n".reddish
	 	client = AyaDN::AppdotnetUserPosts.new(@token)
	 	puts client.getUserPosts(option2)
	 else
	 	puts warnings.errorUsername(option2)
	 end

when option1 == "mentions", option1 == "m"
	if option2 =~ /^@/
		puts "\nChargement des posts mentionnant ".green + "#{option2}...\n".reddish
	 	client = AyaDN::AppdotnetUserMentions.new(@token)
	 	puts client.getUserMentions(option2)
 	else
 		puts warnings.errorUsername(option2)
 	end

when option1 == "stars", option1 == "starred", option1 == "s"
	if option2 =~ /^@/
 		puts "\nChargement des posts favoris de ".green + "#{option2}...\n".reddish
		client = AyaDN::AppdotnetStarredPosts.new(@token)
		puts client.getStarredPosts(option2)
	else
		puts warnings.errorUsername(option2)
	end

when option1 == "tag", option1 == "t"
	client = AyaDN::AppdotnetHashtagSearch.new
	option2_new = option2.dup
	if option2_new =~ /^#/
		option2_new[0] = ""
	end
	puts "\nChargement des posts contenant ".green + "##{option2_new}...\n".blue
	puts client.getTaggedPosts(option2_new)

when option1 == "write", option1 == "w"
	puts "\nEnvoi du post...\n".green
	client = AyaDN::AppdotnetSendPost.new(@token)
	puts client.createPost(option2)

when option1 == "details", option1 == "d"
	if option2.is_integer?
		puts "\nDétails du post...\n".green
		client = AyaDN::AppdotnetPostInfo.new(@token)
		puts client.getPostInfo(option2)
	else
		puts warnings.errorPostID(option2)
	end

when option1 == "help", option1 == "aide", option1 == "h"
	puts @help

else
	puts @help

end





