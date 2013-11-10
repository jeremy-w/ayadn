# encoding: utf-8
@help = ""
#@help += "Options disponibles:\n\n".cyan
#@help += "- " + "flux ".green + "pour voir votre stream unifié + directed posts\n\n" 
@help += "- " + "sans options : affiche le stream unifié + directed posts\n\n"
@help += "- " + "write ".green + "puis 'touche entrée', ou " + 'write \'votre texte\' '.green + "pour créer un post\n"
@help += "- " + "reply postID ".green + "pour répondre à un post\n\n"
@help += "- " + "posts @username ".green + "pour voir les posts d'un utilisateur\n"
@help += "- " + "mentions @username ".green + "pour voir les posts mentionnant un utilisateur\n"
@help += "- " + "stars @username ".green + "pour voir les posts favoris d'un utilisateur\n"
@help += "- " + "tag motclé ".green + "pour chercher les hashtags (ne pas taper le '#')\n"
@help += "- " + "convo postID ".green + "pour lire la conversation autour d'un post\n"
#@help += "- " + "details postID ".green + "pour des informations détaillées sur un post\n"
@help += "- " + "infos @username ".green + "ou " + "infos postID ".green + "pour des informations détaillées sur un utilisateur ou un post\n"
@help += "- " + "global ".green + "pour voir le stream global\n" 
@help += "- " + "help ".green + "ou " + "aide ".green + "pour l'aide. Consultez " + "https://github.com/ericdke/ayadn#how-to-use".magenta + " pour l'aide complète." + "\n\n"

@help += "Toutes les options ont un raccourci à une lettre : w, r, p, m, s, t, c, i, g, h.\n\n".blue
@help += "Exemples :\n".cyan
@help += "ayadn.rb\n".magenta
@help += "ayadn.rb write\n".magenta
@help += "ayadn.rb w ".magenta + '\'Bonjour ADN !\''.magenta + "\n"
@help += "ayadn.rb tag nowplaying\n".magenta
#@help += "ayadn.rb posts @ericd\n".magenta
@help += "ayadn.rb reply 14685167\n".magenta
@help += "\n"