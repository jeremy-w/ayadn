# encoding: utf-8
class AyaDN
	class AppdotnetExplore
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/stream/explore/'
			@token = token
		end
		def getExploreStream(whichStream)
			if whichStream != "checkins"
				@url += "#{whichStream}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0'
			else
				@url += "#{whichStream}" + "?access_token=#{@token}" + '&include_deleted=0&include_html=0&include_annotations=1'
			end
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
			if whichStream == "checkins"
				builder = AyaDN::BuildPosts.new
				resp = builder.buildCheckinsPosts(adnDataReverse)
			else
				builder = AyaDN::BuildPosts.new
				resp = builder.buildPost(adnDataReverse)
			end
			return resp
		end


		def getExploreList
			# https://alpha-api.app.net/stream/0/posts/stream/explore
		end
	end
end