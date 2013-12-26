#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def configAPI
		@time_now = DateTime.now
		api_config_path = $tools.ayadn_configuration[:API_config_path]
		$files.makedir(api_config_path)
		file_API = api_config_path + "/config.json"
		file_timer = api_config_path + "/timer.json"
		if !File.exists?(file_API)
			resp = get_api(file_API, file_timer)
		else
			f = File.open(file_timer, "r")
			    hash_timer = JSON.parse(f.gets)
			f.close
			if DateTime.parse(hash_timer['deadline']) >= @time_now 
				f = File.open(file_API, "r")
				    resp = JSON.parse(f.gets)
				f.close
			else
				resp = get_api(file_API, file_timer)
			end
		end
		$tools.ayadn_configuration[:post_max_length] = resp['data']['post']['text_max_length']
		$tools.ayadn_configuration[:message_max_length] = resp['data']['message']['text_max_length']
	end
	def get_api(file_API, file_timer)
		resp = @api.getAPIConfig
		if resp['meta']['code'] == 200
			f = File.new(file_API, "w")
		    	f.puts(resp.to_json)
			f.close
		end
		hash_timer = {
			"checked" => @time_now,
			"deadline" => @time_now + 1
		}
		f = File.new(file_timer, "w")
		    f.puts(hash_timer.to_json)
		f.close
		return resp
	end
end