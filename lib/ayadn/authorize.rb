#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def ayadnAuthorize(action)
		$files.makedir($tools.ayadn_configuration[:authorization_path])
		if action == "reset"
			$files.reset_credentials
		end
		auth_token = $files.auth_read
		if auth_token == nil
			url = @api.makeAuthorizeURL
			case $tools.ayadn_configuration[:platform]
			when $tools.winplatforms
				puts $status.launchAuthorization("win")
			when /linux/
				puts $status.launchAuthorization("linux")
			else
				puts $status.launchAuthorization("osx")
				$tools.startBrowser(url)
			end
			auth_token = STDIN.gets.chomp()
			$files.auth_write(auth_token)
			puts $status.authorized
			sleep 3
			puts $tools.helpScreen
			puts "Enjoy!\n".cyan
		end
	end
end