#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	class View
		def build_pm_channels_infos
			#meta = @hash['meta']
			#unread_messages = meta['unread_counts']['net.app.core.pm']
			the_channels = ""
			channels_list = []
			puts "\nGetting users infos, please wait a few seconds... (could take a while the first time if you have a lot of channels activated)\n".cyan
			fetched_names = {}
			@hash['data'].each do |item|
				channel_id = item['id']
				channel_type = item['type']
				if channel_type == "net.app.core.pm"
					channels_list.push(channel_id)
					total_messages = item['counts']['messages']
					#owner = "@" + item['owner']['username']
					#readers = item['readers']['user_ids']
					#you_write = item['writers']['you']
					#you_read = item['readers']['you']
					the_writers, the_readers = [], []
					item['writers']['user_ids'].each do |writer|
						if writer != nil
							if fetched_names[writer]
								handle = "@" + fetched_names[writer]
								puts "\n#{writer} already known: #{handle}. Skipping the username search".green
							else
								puts "\nFetching username of user ##{writer}".green
								user = AyaDN::API.new(@token).getUserInfos(writer)
								username = user['data']['username']
								handle = "@" + username
								fetched_names[writer] = username
							end
							$files.save_channel_id(channel_id, handle)
							the_writers.push(handle)
						end
					end
					the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown
					#the_channels << "Creator: ".cyan + owner.magenta + "\n"
					#the_channels << "Channels type: ".cyan + "#{channel_type}\n".brown
					the_channels << "Interlocutor(s): ".cyan + the_writers.join(", ").magenta + "\n"
					the_channels << "Messages: ".cyan + total_messages.to_s.green + "\n"
					if item['recent_message']
						if item['recent_message']['text']
							message_date = objectDate(item['recent_message']).join(" ")
							the_channels << "Last message by @#{item['recent_message']['user']['username']} (#{message_date}): \n".cyan + item['recent_message']['text'] + "\n"
							$files.save_channel_message(channel_id, item['recent_message']['text'], item['recent_message']['user']['username'], message_date)
						end
					end
				end
			end
			the_channels << "\n"
			return the_channels, channels_list
		end
		def build_channels_infos
			the_channels = ""
			channels_list = []
			@hash['data'].each do |item|
				channel_id = item['id']
				channel_type = item['type']
				if channel_type != "net.app.core.pm"
					channels_list.push(channel_id)
					if channel_type == "net.app.ohai.journal"
						$files.save_channel_id(channel_id, "Ohai Journal")
						the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "your Ohai Journal channel\n".green
					elsif channel_type == "net.paste-app.clips"
						$files.save_channel_id(channel_id, "Paste-App Clips")
						the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "your Paste-App Clips channel\n".green
					elsif channel_type == "net.app.core.broadcast"
						item['annotations'].each do |anno|
							if anno['type'] == "net.app.core.broadcast.metadata"
								broadcast_name = anno['value']['title']
								$files.save_channel_id(channel_id, "#{broadcast_name} [Broadcast]")
								the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "Broadcast channel: #{broadcast_name}\n".green
							end
						end
					elsif channel_type == "net.patter-app.room"
						item['annotations'].each do |anno|
							if anno['type'] == "net.patter-app.settings"
								patter_room_name = anno['value']['name']
								$files.save_channel_id(channel_id, "#{patter_room_name} [Patter-App Room]")
								the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "Patter-App Room: #{patter_room_name}\n".green
								next
							end
						end
					else
						$files.save_channel_id(channel_id, channel_type)
						the_channels << "\nChannel ID: ".cyan + "#{channel_id}\n".brown + " -> " + "#{channel_type}\n"
					end
					if item['recent_message']
						if item['recent_message']['text']
							message_date = objectDate(item['recent_message']).join(" ")
							the_channels << "Last message by @#{item['recent_message']['user']['username']} (#{message_date}): \n".cyan + item['recent_message']['text'] + "\n"
							$files.save_channel_message(channel_id, item['recent_message']['text'], item['recent_message']['user']['username'], message_date)
						end
					end
				end
			end
			the_channels << "\n"
			return the_channels, channels_list
		end
	end
end