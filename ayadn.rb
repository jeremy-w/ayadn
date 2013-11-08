#!/usr/bin/ruby
# Read-only App.net client
# Learning Ruby and ADN
# by Eric Dejonckheere
# © 2013

require_relative 'Requires'
winPlatforms = ['mswin', 'mingw', 'mingw_18', 'mingw_19', 'mingw_20']
case Gem::Platform.local.os
when *winPlatforms
	require 'win32console'
end

token = ''

help = "\nOptions disponibles:\n\n".cyan
help += "- " + "stream ".green + "pour voir le Stream\n\n" 
help += "- " + "infos @username ".green + "pour voir les informations de cet utilisateur\n\n"
help += "- " + "posts @username ".green + "pour voir les posts de cet utilisateur\n\n"
help += "- " + "mentions @username ".green + "pour voir les posts mentionnant cet utilisateur\n\n"
help += "- " + "stars @username ".green + "pour voir les posts favoris de cet utilisateur\n\n"
help += "- " + "tag motclé ".green + "pour chercher les hashtags (ne pas taper le '#')\n\n"
help += "- " + "help ".green + "ou " + "aide ".green + "pour afficher l'aide\n\n"
help += "La commande sans options affiche le Stream.\n\n\n".green
help += "Exemples d'utilisation :\n\n".cyan
help += "ayadn.rb stream\n".magenta
help += "ayadn.rb tag hello\n".magenta
help += "ayadn.rb posts @ericd\n".magenta
help += "\n"

puts "\nAYADN".red
puts "App.net read-only command-line client\n".reddish

option1 = ARGV[0]
option2 = ARGV[1]

case
when !option1, option1 == "stream", option1 == "s"
	puts "\nChargement du Unified Stream...\n".green
	client = AyaDN::AppdotnetUnified.new(token)
	puts client.getText()
when option1 == "infos"
	puts "\nChargement des informations sur ".green + "#{option2}...\n".reddish
	client = AyaDN::AppdotnetUserInfo.new(token)
	puts client.getUserInfo(option2)
when option1 == "posts"
	puts "\nChargement des posts de ".green + "#{option2}...\n".reddish
 	client = AyaDN::AppdotnetUserPosts.new(token)
 	puts client.getUserPosts(option2)
when option1 == "mentions"
	puts "\nChargement des posts mentionnant ".green + "#{option2}...\n".reddish
 	client = AyaDN::AppdotnetUserMentions.new(token)
 	puts client.getUserMentions(option2)
when option1 == "stars", option1 == "starred"
 	puts "\nChargement des posts favoris de ".green + "#{option2}...\n".reddish
	client = AyaDN::AppdotnetStarredPosts.new(token)
	puts client.getStarredPosts(option2)
when option1 == "tag"
	puts "\nChargement des posts contenant ".green + "##{option2}...\n".reddish
	client = AyaDN::AppdotnetHashtagSearch.new
	puts client.getTaggedPosts(option2)
when option1 == "help", option1 == "aide"
	puts help
else
	puts help
end





