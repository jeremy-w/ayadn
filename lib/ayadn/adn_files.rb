#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def ayadn_download_files(target)
		with_url = false
		$files.makedir($tools.ayadn_configuration[:files_path])
		if target.split(",").length == 1
 			view, file_url, file_name = @view.new(@api.getSingleFile(target)).showFileInfo(with_url)
 			puts "\nDownloading file ".green + target.to_s.brown
 			puts view
 			$files.download_file(file_url, "#{file_name}", @token)
 		else
 			@hash = @api.getMultipleFiles(target)
 			@hash['data'].each do |unique_file|
	 			view, file_url, file_name = @view.new(nil).buildFileInfo(unique_file, with_url)
	 			unique_file_id = unique_file['id']
	 			puts "\nDownloading file ".green + unique_file_id.to_s.brown
	 			puts view
	 			$files.download_file(file_url, "#{unique_file_id}_#{file_name}", @token)
	 		end
 		end
 	end
 	def ayadn_delete_file(target)
 		puts "\nWARNING: ".red + "delete a file ONLY is you're sure it's not referenced by a post or a message.\n\n".pink
		puts "Do you wish to continue? (y/N) ".reddish
		if STDIN.getch == ("y" || "Y")
			puts "\nPlease wait...".green
			$files.delete_file(target, @token)
			puts "\nDone!\n\n".green
		else
			puts "\n\nCanceled.\n\n".red
			exit
		end
 	end
 	def ayadn_upload_files(target)
 		case $tools.ayadn_configuration[:platform]   
        when $tools.winplatforms
        	puts "\nThis feature doesn't work on Windows yet. Sorry.\n\n".red
        	exit
        end
        $files.makedir($tools.ayadn_configuration[:files_path])
		uploaded_ids = []
		target.split(",").each do |file|
			puts "Uploading ".cyan + "#{File.basename(file)}".brown + "\n\n"
			begin
				resp = JSON.parse($files.uploadFiles(file, @token))
			rescue => e
				puts "\nERROR: ".red + e.inspect.red + "\n\n"
				exit
			end
			$tools.meta(resp['meta'])
			uploaded_ids.push(resp['data']['id'])
		end
		params = @view.new(@api.getFilesList(nil)).showFilesList(nil, false)
		uploaded_ids.each do |id|
			params[0].gsub!("#{id}", "#{id}".reverse_color)
		end
		puts params[0]
 	end
 	def ayadn_attribute_file(attribute, target)
		puts "\nChanging file attribute...".green
		if attribute == "public"
			data = {
				"public" => true
			}.to_json
		else
			data = {
				"public" => false
			}.to_json
		end
		response = @api.httpPutFile(target, data)
		resp = JSON.parse(response.body)
		meta = resp['meta']
		if meta['code'] == 200
			puts "\nDone!\n".green
			changed_file_id = resp['data']['id']
			params = @view.new(@api.getFilesList(nil)).showFilesList(nil, false)
			params[0].gsub!("#{changed_file_id}", "#{changed_file_id}".reverse_color)
			puts params[0]
		else
			puts "\nERROR: #{meta.inspect}\n".red
		end
 	end
end