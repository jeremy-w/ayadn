# encoding: utf-8
class AyaDN
	class AppdotnetWhoReposted
		@token
		@url
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/'
			@token = token
		end
		def getUsers(postID)
			@url += "#{postID}" + "/reposters" + "/?access_token=#{@token}"
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
		def getRepostedByUsers(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			repostedByUsers = hashOfResponse['data']
			if repostedByUsers.empty?
				puts "This post hasn't been reposted by anyone.\n\n".red
				exit
			end
			resp = buildUsersList(repostedByUsers)
			return resp
		end
	end
end