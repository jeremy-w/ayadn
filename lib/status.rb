#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
    class ClientStatus
        def showList(list, name)
            if list == "muted"
                "Your list of muted users:\n".green
            elsif list == "followings"
                "List of users ".green + "#{name} ".brown + "is following:\n".green
            elsif list == "followers"
                "List of ".green + "#{name}".brown + "'s followers:\n".green
            end
        end
        def getInteractions
            "\nLoading the ".green + "interactions ".brown + "informations.\n".green
        end
        def launchAuthorization(os)
            if os == "osx"
                "\nAyaDN opened a browser to authorize via App.net very easily. Just login with your App.net account, then copy the code it will give you, paste it here then press [ENTER].".pink + " Paste authorization code: \n\n".brown
            else
                s = "\nPlease open a browser and paste this URL: \n\n".brown
                s += "https://account.app.net/oauth/authenticate?client_id=hFsCGArAjgJkYBHTHbZnUvzTmL4vaLHL&response_type=token&redirect_uri=http://aya.io/ayadn/auth.html&scope=basic stream write_post follow public_messages messages&include_marker=1"
                s += "\n\nOn this page, login with your App.net account, then copy the code it will give you, paste it here then press [ENTER].".pink + " Paste authorization code: \n\n".brown
            end
        end
        def authorized
            "\nThank you for authorizing AyaDN. You won't need to do this anymore.\n\n".green
        end
        def noNewPosts
            "\nNo new posts since your last visit.\n\n".red
        end
        def errorEmptyList
            "\nThe list is empty.\n\n".red
        end
        def errorSyntax
            "\nSyntax error.\n\n".red
        end
        def errorNotAuthorized
            "\nYou haven't authorized AyaDN yet.\n\n".red
        end
        def errorNobodyReposted
            "\nThis post hasn't been reposted by anyone.\n\n".red
        end
        def errorNobodyStarred
            "\nThis post hasn't been starred by anyone.\n\n".red
        end
        def errorNoID
            "\nError -> you must give a post ID to reply to.\n\n".red
        end
        def emptyPost
            "\nError -> there was no text to post.\n\n".red
        end
        def errorInfos(arg)
            "\nError -> ".red + "#{arg}".brown + " isn't a @username or a Post ID\n\n".red
        end
        def errorUserID(arg)
            "\nError -> ".red + "#{arg}".brown + " is not a @username\n\n".red
        end
        def errorPostID(arg)
            "\nError -> ".red + "#{arg}".brown + " is not a Post ID\n\n".red
        end
        def errorMessageNotSent
            "\n\nCanceled. Your message hasn't been sent.\n\n".red
        end
        def errorMessageTooLong(realLength, to_remove)
            "\nError: your message is ".red + "#{realLength} ".brown + "characters long, please remove ".red + "#{to_remove} ".brown + "characters.\n\n".red
        end
        def errorPostTooLong(realLength, to_remove)
            "\nError: your post is ".red + "#{realLength} ".brown + " characters long, please remove ".red + "#{to_remove} ".brown + "characters.\n\n".red
        end
        def errorPostNotSent
            "\n\nCanceled. Your post hasn't been sent.\n\n".red
        end
        def errorIsRepost(postID)
            "\n#{postID} ".brown + " is a repost.\n".red
        end
        def errorAlreadyDeleted
            "\nPost already deleted.\n\n".red
        end
        def redirectingToOriginal(postID)
            "Redirecting to the original post: ".cyan + "#{postID}\n".brown
        end
        def fetchingList(list)
            "\nFetching the \'#{list}\' list. Please wait\n".green
        end
        def getUnified
            "\nLoading the ".green + "unified ".brown + "Stream".green
        end
        def getExplore(explore)
            "\nLoading the ".green + "#{explore}".brown + " Stream".green
        end
        def getGlobal
            "\nLoading the ".green + "global ".brown + "Stream".green
        end
        def whoReposted(arg)
            s = "\nLoading informations on post ".green + "#{arg}".brown + "\n "
            s += "\nReposted by: \n".cyan
        end
        def whoStarred(arg)
            s = "\nLoading informations on post ".green + "#{arg}".brown + "\n"
            s += "\nStarred by: \n".cyan
        end
        def infosUser(arg)
            "\nLoading informations on ".green + "#{arg}".brown + "\n"
        end
        def infosPost(arg)
            "\nLoading informations on post ".green + "#{arg}".brown + "\n"
        end
        def postsUser(arg)
            "\nLoading posts of ".green + "#{arg}".brown + "\n"
        end
        def mentionsUser(arg)
            "\nLoading posts mentionning ".green + "#{arg}".brown + "\n"
        end
        def starsUser(arg)
            "\nLoading ".green + "#{arg}".reddish + "'s favorite posts\n".green
        end
        def starsPost(arg)
            "\nLoading users who starred post ".green + "#{arg}".reddish + "\n"
        end
        def getHashtags(arg)
            "\nLoading posts containing ".green + "##{arg}".pink + "\n".green
        end
        def sendPost
            "\nSending post\n".green
        end
        def sendMessage
            "\nSending private Message\n".green
        end
        def postSent
            "Successfully posted\n".green
        end
        def postDeleted
            "\nPost successfully deleted\n".green
        end
        def replyingToPost(postID)
            "\nReplying to post ".cyan + "#{postID}\n".brown
        end
        def deletePost(postID)
            "\nDeleting post ".green + "#{postID}".brown + "\n"
        end
        def getPostReplies(arg)
            "\nLoading the conversation around post ".green + "#{arg}".brown + "\n"
        end
        def writePost
            s = "\n#{$tools.ayadn_configuration[:post_max_length]} characters max, validate with [Enter] or cancel with [CTRL+C].\n".green
            s += "\nType your text: ".cyan
        end
        def writeMessage
            s = "\n#{$tools.ayadn_configuration[:message_max_length]} characters max, validate with [Enter] or cancel with [CTRL+C].\n".green
            s += "\nType your text: ".cyan + "\n\n"
        end
        def writeReply(arg)
            "\nLoading informations of post " + "#{arg}".brown + "\n"
        end
        def savingFile(name, path, file)
            "\nSaving ".green + "#{name} ".brown + "in ".green + "#{path}#{file}".magenta
        end
        def stopped
            "\n\nStopped.\n\n".red
        end
    end
end