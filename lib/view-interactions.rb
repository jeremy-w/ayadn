#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class View
		def buildInteractions(hash)
			inter_string = ""
			hash.each do |item|
				action = item['action']
				created_day = item['event_date'][0...10]
				created_hour = item['event_date'][11...19]
				objects_names, users_list, post_ids, post_text = [], [], [], [] # not the same as var1 = var2 = []
				item['objects'].each do |o|
					case action
					when "follow", "unfollow", "mute", "unmute"
						objects_names.push("@" + o['username'])
					when "star", "unstar", "repost", "unrepost", "reply"
						post_ids.push(o['id'])
						text = o['text']
						post_info = buildPostInfo(o, false)
						post_text.push(post_info.chomp("\n\n"))
						#post_text << text
					end
				end
				item['users'].each do |u|
					if u != nil
						users_list.push("@" + u['username'])
					end
				end
				joined_users_list = users_list.join(", ")
				joined_post_text = post_text.join(" ")
				inter_string << "-----\n\n".blue
				inter_string << "Date: ".green + "#{created_day} #{created_hour}\n".cyan
				case action
				when "follow", "unfollow"
					inter_string << "#{joined_users_list} ".green + "#{action}ed ".magenta + "you\n".brown
				when "mute", "unmute"
					inter_string << "#{joined_users_list} ".green + "#{action}d ".magenta + "#{objects_names.join(", ")}\n".brown
				when "repost", "unrepost"
					inter_string << "#{joined_users_list} ".green + "#{action}ed:\n".magenta
					inter_string << joined_post_text
				when "star", "unstar"
					inter_string << "#{joined_users_list} ".green + "#{action}red:\n".magenta
					inter_string << joined_post_text
				when "reply"
					inter_string << "#{joined_users_list} ".green + "#{action}ed to:\n".magenta
					inter_string << joined_post_text
				when "welcome"
					inter_string << "App.net ".green + "welcomed ".magenta + "you.\n".green
				else
					inter_string << "Unknown data.\n".red
				end
				inter_string << "\n"
			end
			return inter_string
		end
	end
end