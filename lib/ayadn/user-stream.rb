#!/usr/bin/env ruby
# encoding: utf-8
require 'net/http'
require 'openssl'

class AyaDN

	# EXPERIMENT!!!

 	def ayadn_userstream
 		# first create with curl -i -H 'Authorization: BEARER xxx' "https://stream-channel.app.net/stream/user?auto_delete=1&include_annotations=1&include_html=0"
 		# it stays open and returns a stream_id in the headers
 		# TODO: replace curl with a good connection system: HTTP or Rest-Client

 		puts "1. Create user stream\n".cyan
 		puts "2. Connect to user stream\n".cyan
 		puts "\n\nYour choice? \n\n".brown
 		case STDIN.getch
 		when "1"
 			command = "sleep 1; curl -i -H 'Authorization: BEARER #{@token}' 'https://stream-channel.app.net/stream/user?auto_delete=1&include_annotations=1&include_html=0'"
 			pid = Process.spawn(command)
        	Process.detach(pid)
        	exit
 		when "2"
 			puts "Paste stream id: "
 			stream_id = STDIN.gets.chomp
 		else
 			puts $status.errorSyntax
 		end
 		last_page_id = nil
 		start = Time.now
 		$files.makedir($tools.ayadn_configuration[:data_path] + "/.temp/")
 		f = File.new($tools.ayadn_configuration[:data_path] + "/.temp/#{stream_id}", "w")
 		f.puts(stream_id)
 		f.close
 		@url = "https://alpha-api.app.net/stream/0/posts/stream/global?connection_id=#{stream_id}&since_id=#{last_page_id}&include_deleted=0"
		uri = URI.parse(@url)
		https = Net::HTTP.new(uri.host,uri.port)
		https.use_ssl = true
		https.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(uri.request_uri)
		request["Authorization"] = "Bearer #{@token}"
		request["Content-Type"] = "application/json"
		response = https.request(request)
		@hash = JSON.parse(response.body)
		stream, last_page_id = completeStream
		displayScrollStream(stream)
		number_of_connections = 1
		total_size = 0
		loop do
 			begin
		 		@url = "https://alpha-api.app.net/stream/0/posts/stream/global?connection_id=#{stream_id}&since_id=#{last_page_id}&include_deleted=0"
 				uri = URI.parse(@url)
 				request = Net::HTTP::Get.new(uri.request_uri)
 				request["Authorization"] = "Bearer #{@token}"
 				request["Content-Type"] = "application/json"
 				before_request_id = last_page_id
				response = https.request(request)
				chunk_size = response['Content-Length']
				@hash = JSON.parse(response.body)
				stream, last_page_id = completeStream
				displayScrollStream(stream)
				last_page_id = before_request_id if last_page_id == nil
				number_of_connections += 1
				# puts "\nData chunks: \t#{number_of_connections}".magenta
				# puts "Chunk size: \t#{chunk_size.to_i.to_filesize}".magenta
				total_size += chunk_size.to_i
				# puts "Total size: \t#{total_size.to_filesize}".magenta
				# finish = Time.now
				# elapsed = finish.to_f - start.to_f
				# mins, secs = elapsed.divmod 60.0
				# puts "Total time:\t".magenta + "%3d:%04.2f".magenta%[mins.to_i, secs]
				# req_sec = number_of_connections.to_f/secs
				# puts "Req/sec: \t#{req_sec.round(2)}".magenta
			rescue Exception => e
				puts "\n\n"
				puts e.inspect
				finish = Time.now
				elapsed = finish.to_f - start.to_f
				mins, secs = elapsed.divmod 60.0
				puts "\n\nData chunks: #{number_of_connections}\n"
				puts "Total size: #{total_size.to_filesize}"
				puts "Elapsed time (min:secs.msecs): "
				puts("%3d:%04.2f"%[mins.to_i, secs])
				req_sec = number_of_connections.to_f/secs.to_f
				puts "Req/sec: #{req_sec.round(2)}\n\n"
				exit
			end
		end
 	end
end
