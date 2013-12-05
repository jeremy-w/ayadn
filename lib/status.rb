class AyaDN
    class ClientStatus
        def getInteractions
            s = "\nLoading the ".green + "interactions ".brown + "informations.\n\n".green
        end
        def launchAuthorization(os)
            if os == "osx"
                s = "\nAyaDN opened a browser to authorize via App.net very easily. Just login with your App.net account, then copy the code it will give you, paste it here then press [ENTER].".pink + " Paste authorization code: \n\n".brown
            else
                s = "\nPlease open a browser and paste this URL: \n\n".brown
                s += "https://account.app.net/oauth/authenticate?client_id=hFsCGArAjgJkYBHTHbZnUvzTmL4vaLHL&response_type=token&redirect_uri=http://aya.io/ayadn/auth.html&scope=basic stream write_post follow public_messages messages&include_marker=1"
                s += "\n\nOn this page, login with your App.net account, then copy the code it will give you, paste it here then press [ENTER].".pink + " Paste authorization code: \n\n".brown
            end
        end
        def authorized
            s = "\nThank you for authorizing AyaDN. You won't need to do this anymore.\n\n".green
        end
        def noNewPosts
            s = "No new posts since your last visit.\n\n".red
        end
        def errorSyntax
            s = "\nSyntax error.\n\n".red
        end
        def errorNotAuthorized
            s = "\nYou haven't authorized AyaDN yet.\n\n".red
        end
        def errorNobodyReposted
            s = "\nThis post hasn't been reposted by anyone.\n\n".red
        end
        def errorNobodyStarred
            s = "\nThis post hasn't been starred by anyone.\n\n".red
        end
        def errorNoID
            s = "\nError -> you must give a post ID to reply to.\n\n".red
        end
        def emptyPost
            s = "\nError -> there was no text to post.\n\n".red
        end
        def errorInfos(arg)
            s = "\nError -> ".red + "#{arg}".brown + " isn't a @username or a Post ID\n\n".red
        end
        def errorUserID(arg)
            s = "\nError -> ".red + "#{arg}".brown + " is not a @username\n\n".red
        end
        def errorPostID(arg)
            s = "\nError -> ".red + "#{arg}".brown + " is not a Post ID\n\n".red
        end
        def errorMessageNotSent
            s = "\n\nCanceled. Your message hasn't been sent.\n\n".red
        end
        def errorMessageTooLong(realLength, to_remove)
            s = "\nError: your message is ".red + "#{realLength} ".brown + " characters long, please remove ".red + "#{to_remove} ".brown + "characters.\n\n".red
        end
        def errorPostTooLong(realLength, to_remove)
            s = "\nError: your post is ".red + "#{realLength} ".brown + " characters long, please remove ".red + "#{to_remove} ".brown + "characters.\n\n".red
        end
        def errorPostNotSent
            s = "\n\nCanceled. Your post hasn't been sent.\n\n".red
        end
        def errorIsRepost(postID)
            s = "\n#{postID} ".brown + " is a repost.\n".red
        end
        def errorAlreadyDeleted
            s = "\nPost already deleted.\n\n".red
        end
        def redirectingToOriginal(postID)
            s = "Redirecting to the original post: ".cyan + "#{postID}\n".brown
        end
        def fetchingList(list)
            s = "\nFetching the \'#{list}\' list. Please wait...\n\n".green
        end
        def getUnified
            s = "\nLoading the ".green + "unified ".brown + "Stream...\n".green
        end
        def getExplore(explore)
            s = "\nLoading the ".green + "#{explore}".brown + " stream.".green
        end
        def getGlobal
            s = "\nLoading the ".green + "global ".brown + "Stream...\n".green
        end
        def whoReposted(arg)
            s = "\nLoading informations on post ".green + "#{arg}".brown + "...\n ".green
            s += "\nReposted by: \n".cyan
        end
        def whoStarred(arg)
            s = "\nLoading informations on post ".green + "#{arg}".brown + "...\n".green
            s += "\nStarred by: \n".cyan
        end
        def infosUser(arg)
            s = "\nLoading informations on user ".green + "#{arg}".brown + "...\n".green
        end
        def infosPost(arg)
            s = "\nLoading informations on post ".green + "#{arg}".brown + "...\n".green
        end
        def postsUser(arg)
            s = "\nLoading posts of ".green + "#{arg}".brown + "...\n".green
        end
        def mentionsUser(arg)
            s = "\nLoading posts mentionning ".green + "#{arg}".brown + "...\n".green
        end
        def starsUser(arg)
            s = "\nLoading ".green + "#{arg}".reddish + "'s favorite posts...\n".green
        end
        def starsPost(arg)
            s = "\nLoading users who starred post ".green + "#{arg}".reddish + "...\n" .green
        end
        def getHashtags(arg)
            s = "\nLoading posts containing ".green + "##{arg}".pink + "...\n".green
        end
        def sendPost
            s = "\nSending post...\n".green
        end
        def sendMessage
            s = "\nSending private Message...\n".green
        end
        def postSent
            s = "Successfully posted.\n".green
        end
        def postDeleted
            s = "\nPost successfully deleted.\n\n".green
        end
        def replyingToPost(postID)
            s = "Replying to post ".cyan + "#{postID}...\n".brown
        end
        def deletePost(postID)
            s = "\nDeleting post ".green + "#{postID}".brown + "...\n".green
        end
        def getPostReplies(arg)
            s = "\nLoading the conversation around post ".green + "#{arg}".brown + "...\n".green
        end
        def writePost
            s = "\n256 characters max, validate with [Enter] or cancel with [CTRL+C].\n".green
            s += "\nType your text: ".cyan
        end
        def writeMessage
            s = "\n2048 characters max, validate with [Enter] or cancel with [CTRL+C].\n".green
            s += "\nType your text: ".cyan + "\n\n"
        end
        def writeReply(arg)
            s = "\nLoading informations of post " + "#{arg}".brown + "...\n".green
        end
        def savingFile(name, path, file)
            s = "\nSaving ".green + "#{name} ".brown + "in ".green + "#{path}#{file}".magenta
        end
        def stopped
            s = "\n\nStopped.\n\n".red
        end
    end
end