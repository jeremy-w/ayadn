class AyaDN
	class AppdotnetExplore
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/stream/explore/'
			@token = token
		end
		def getExploreStream(whichStream)
			@url += "#{whichStream}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0'
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON(whichStream)
			return getExploreStream(whichStream)
		end
		def getText(whichStream)
			hashOfResponse = JSON.parse(getJSON(whichStream))
			adnData = hashOfResponse['data']
			adnDataReverse = adnData.reverse
			resp = buildPost(adnDataReverse)
			return resp
		end


		def getExploreList
			# https://alpha-api.app.net/stream/0/posts/stream/explore
		end
	end
end