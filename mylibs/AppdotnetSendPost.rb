# encoding: utf-8
class AyaDN
	class AppdotnetSendPost
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@token = token
		end
		def createPost(text)
			uri = URI("#{@url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"

			payload = {
				"text" => "#{text}"
			}.to_json

			response = https.request(request, payload)
			callback = response.body

			blob = JSON.parse(callback)
			adnData = blob['data']
			resp = buildUniquePost(adnData)
			return resp
		end
	end
end
