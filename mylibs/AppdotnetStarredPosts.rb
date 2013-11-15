# encoding: utf-8
class AyaDN
	class AppdotnetStarredPosts
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/' 
			@token = token
		end
		def getPosts(name)
			@url += "#{name}" + "/stars" + "/?access_token=#{@token}" + "&include_deleted=0&include_html=0"
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON(name)
		 	return getPosts(name)
		end
		def getStarredPosts(name)
			hashOfResponse = JSON.parse(getJSON(name))
			starredPosts = hashOfResponse['data']
			if starredPosts == nil
				puts "\n\nNo starred posts by this user.\n\n"
				exit
			end
			starredPostsReverse = starredPosts.reverse
			builder = AyaDN::BuildPosts.new
			resp = builder.buildPost(starredPostsReverse)
			return resp
		end
	end
	class AppdotnetWhoStarred
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/'
			@token = token
		end
		def getUsers(postID)
			@url += "#{postID}" + "/stars" + "/?access_token=#{@token}"
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON(postID)
			return getUsers(postID)
		end
		def getStarredByUsers(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			starredByUsers = hashOfResponse['data']
			if starredByUsers == nil
				puts "\n\nThis post hasn't been starred by anyone.\n\n"
				exit
			end
			starredByUsersInverse = starredByUsers.reverse
			resp = buildUsersList(starredByUsersInverse)
			return resp
		end
	end
 end







