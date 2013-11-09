class AyaDN
	class AppdotnetUnified
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/stream/unified?access_token='
			@token = token
		end
		def getUnified
			@url += @token + '&include_deleted=0&include_directed_posts=1&include_html=0'
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON
			return getUnified()
		end
		def getText
			hashOfResponse = JSON.parse(getJSON())
			adnData = hashOfResponse['data']
			adnDataReverse = adnData.reverse
			resp = buildPost(adnDataReverse)
			return resp
		end
	end
end