# encoding: utf-8
@help = ""
@help += "- " + "without options: display the Unified stream + your directed posts\n\n"
@help += "- " + "write ".green + "+ [Enter key], or " + 'write \'your text\' '.green + "to create a post\n"
@help += "- " + "reply postID ".green + "to reply to a post\n"
@help += "- " + "star postID ".green + "to star a post\n"
@help += "- " + "unstar postID ".green + "to unstar a post\n"
@help += "- " + "delete postID ".green + "to delete a post\n"
@help += "- " + "posts @username ".green + "to display a user's posts\n"
@help += "- " + "mentions @username ".green + "to display posts mentionning a user\n"
@help += "- " + "starred @username ".green + "to display a user's starred posts\n"
@help += "- " + "tag hashtag ".green + "to search for hashtags (don't write the '#')\n"
@help += "- " + "convo postID ".green + "to display the conversation around a post\n"
@help += "- " + "infos @username ".green + "or " + "infos postID ".green + "to display detailed informations on a user or a post\n"
@help += "- " + "follow/unfollow @username ".green + "to follow/unfollow a user\n"
@help += "- " + "global/trending/checkins/conversations ".green + "to display the other streams\n" 
@help += "- " + "help ".green + "to display this screen. See " + "https://github.com/ericdke/ayadn#how-to-use".magenta + " for even more detailed instructions." + "\n\n"
@help += "Most options have a one-letter shortcut: w, r, p, m, s, t, c, i, g, h.\n\n".blue
@help += "Examples:\n".cyan
@help += "ayadn.rb\n".magenta
@help += "ayadn.rb write\n".magenta
@help += "ayadn.rb w ".magenta + '\'Good morning ADN!\''.magenta + "\n"
@help += "ayadn.rb tag nowplaying\n".magenta
@help += "ayadn.rb reply 14685167\n".magenta
@help += "ayadn.rb star 14685167\n".magenta
@help += "ayadn.rb checkins\n".magenta
@help += "\n"