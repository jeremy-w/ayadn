# encoding: utf-8
@help = "\nOptions disponibles:\n\n".cyan
@help += "- " + "flux ".green + "pour voir votre stream unifié + directed posts\n\n" 
@help += "- " + "posts @username ".green + "pour voir les posts d'un utilisateur\n\n"
@help += "- " + "mentions @username ".green + "pour voir les posts mentionnant un utilisateur\n\n"
@help += "- " + "stars @username ".green + "pour voir les posts favoris d'un utilisateur\n\n"
@help += "- " + "tag motclé ".green + "pour chercher les hashtags (ne pas taper le '#')\n\n"
@help += "- " + "convo postID ".green + "pour lire la conversation autour d'un post\n\n"
@help += "- " + "details postID ".green + "pour des informations détaillées sur un post\n\n"
@help += "- " + "infos @username ".green + "pour des informations détaillées sur un utilisateur\n\n"
@help += "- " + "global ".green + "pour voir le stream global\n\n" 
@help += "- " + "help ".green + "ou " + "aide ".green + "pour l'aide. Consultez " + "https://github.com/ericdke/ayadn#how-to-use".magenta + " pour l'aide complète.".green + "\n\n\n"
@help += "- " + "write ".green + '\'votre texte\' '.green + "pour poster un texte (guillemets simples obligatoires)\n\n\n"
@help += "La commande sans options affiche le Stream.\n\n".brown
@help += "Toutes les options ont un raccourci à une lettre : f, g, i, p, m, s, t, d, c, h, w.\n\n\n".blue
@help += "Exemples d'utilisation :\n\n".cyan
@help += "ayadn.rb\n".magenta
@help += "ayadn.rb flux\n".magenta
@help += "ayadn.rb write ".magenta + '\'Bonjour ADN !\'' + "\n"
@help += "ayadn.rb tag nowplaying\n".magenta
@help += "ayadn.rb posts @ericd\n".magenta
@help += "ayadn.rb convo 14638413\n".magenta
@help += "\n"