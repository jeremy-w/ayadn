#!/usr/bin/env ruby
require 'base64'
require 'open-uri'

# encoding: utf-8
class AyaDN
	def ayadnBookmark(*args)
		post_id = args[0][1]
		tags = args[0][2]
		hash = @api.getSinglePost(post_id)
		data = hash['data']
		post_text = data['text']
		user_name = data['user']['username']
		link = data['entities']['links'][0]['url']
		if $tools.config['pinboard']['username'] != nil
			puts "\nSaving post ".green + post_id.brown + " to Pinboard...\n".green
			$tools.saveToPinboard(post_id, $tools.config['pinboard']['username'], URI.unescape(Base64::decode64($tools.config['pinboard']['password'])), link, tags, post_text, user_name)
			puts "Done!\n\n".green
		else
			puts "\nConfiguration does not include your Pinbard credentials.\n".red
			begin
				puts "Please enter your Pinboard username (CTRL+C to cancel): ".green
				pin_username = STDIN.gets.chomp()
				puts "\nPlease enter your Pinboard password (invisible, CTRL+C to cancel): ".green
				pin_password = STDIN.noecho(&:gets).chomp()
			rescue Exception
				abort($status.stopped)
			end
			$tools.config['pinboard']['username'] = pin_username
			$tools.config['pinboard']['password'] = URI.escape(Base64::encode64(pin_password))
			$tools.saveConfig
			puts "Saving post ".green + post_id.brown + " to Pinboard...\n".green
			$tools.saveToPinboard(post_id, pin_username, pin_password, link, tags, post_text, user_name)
			puts "Done!\n\n".green
		end
 	end
end
