#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def ayadn_skip_add(kind, target) #kind: sources,hashtags,mentions
		puts "Current skipped #{kind}: ".green + $tools.config['skipped']["#{kind}"].join(", ").red + "\n\n"
		puts "Adding ".green + target.red + " to the skipped #{kind}.".green + "\n\n"
		$tools.config['skipped']["#{kind}"].each do |config|
			if config == target
				puts target.red + " is already skipped.\n\n".green
				exit
			end
		end
		$tools.config['skipped']["#{kind}"].push(target)
		puts "New skipped #{kind}: ".green + $tools.config['skipped']["#{kind}"].join(", ").red + "\n\n"
		$tools.saveConfig
	end
	def ayadn_skip_remove(kind, target)
		puts "Removing ".green + target.red + " from the skipped #{kind}.".green + "\n\n"
		$tools.config['skipped']["#{kind}"].each do |config|
			if config == target
				$tools.config['skipped']["#{kind}"].delete(config)
			end
		end
		puts "New skipped #{kind}: ".green + $tools.config['skipped']["#{kind}"].join(", ").red + "\n\n"
		$tools.saveConfig
	end
end