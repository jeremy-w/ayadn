# encoding: utf-8
class AyaDN
	class AppdotnetGlobal
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/stream/global?access_token='
			@token = token
		end
		def getGlobal
			@url += @token + '&include_deleted=0&include_html=0'
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON
			return getGlobal()
		end
		def getText
			hashOfResponse = JSON.parse(getJSON())
			adnData = hashOfResponse['data']
			adnDataReverse = adnData.reverse
			builder = AyaDN::BuildPosts.new
			resp = builder.buildPost(adnDataReverse)
			return resp
		end
	end
end