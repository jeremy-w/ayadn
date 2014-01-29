#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def ayadn_list_files(value)
		with_url = false
		if value == "all"
			puts "\nGetting the list of all your files...\n".green
			beforeID = nil
			i = 1
	    	loop do
	    		params = @view.new(@api.getFilesList(beforeID)).showFilesList(with_url, true)
	    		beforeID = params[2].last
	    		break if beforeID == nil
					puts params[0]
					i += 1
	    		if params[2].first != nil
	    			$tools.countdown(5) unless i == 2
	    			print "\r" + (" " * 40) unless i == 2
	    			print "\n\nPlease wait, fetching page (".cyan + "#{beforeID}".pink + ")...\n".cyan unless i == 2
	    		end
			end
			puts "\n"
		else
			puts "\nGetting the list of your recent files...\n".green
			params = @view.new(@api.getFilesList(nil)).showFilesList(with_url, false)
			puts params[0]
		end
 	end
	def fetch_list(list, name, beforeID)
		case list
		when "followers"
			@api.getFollowers(name, beforeID)
		when "followings"
			@api.getFollowings(name, beforeID)
		when "muted"
			@api.getMuted(name, beforeID)
		when "blocked"
			@api.getBlocked(name, beforeID)
		end
	end
	def getList(list, name)
		beforeID = nil
		big_hash = {}
		@progress_indicator = false
	    loop do
			@hash = fetch_list(list, name, beforeID)
		    users_hash, min_id = @view.new(@hash).buildFollowList
		    big_hash.merge!(users_hash)
	    	break if min_id == nil
	    	beforeID = min_id
		end
		big_hash
	end

	def ayadnShowList(list, name)
		puts $status.fetchingList(list)
		puts $status.showList(list, name)
		users, number = @view.new(getList(list, name)).showUsers
		puts "\n"
		if number == 0
			puts $status.errorEmptyList
			exit
		end
		puts users
		puts "Number of users: ".green + " #{number}\n\n".brown
	end

	def ayadnSaveList(list, name) # to be called with: var = ayadnSaveList("followers", "@ericd")
		@progress_indicator = false
		fileURL = $tools.ayadn_configuration[:lists_path] + "/#{name}-#{list}.json"
		unless Dir.exists?$tools.ayadn_configuration[:lists_path]
			puts "Creating lists directory in ".green + "#{$tools.ayadn_configuration[:data_path]}".brown + "\n"
			FileUtils.mkdir_p $tools.ayadn_configuration[:lists_path]
		end
		if File.exists?(fileURL)
			puts "\nYou already saved this list.\n".red
			puts "Delete the old one and replace with this one? (n/y)\n".red
			abort("\nCanceled.\n\n".red) unless STDIN.getch == ("y" || "Y")
		end
		puts $status.showList(list, name)
		puts "Please wait...\n".green
		puts "Saving the list...\n".green
		f = File.new(fileURL, "w")
			f.puts(getList(list, name).to_json)
		f.close
		puts "\nSuccessfully saved the list.\n\n".green
		exit
	end
end