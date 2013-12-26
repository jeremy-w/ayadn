#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def debugStream
		puts @view.new(@hash).showDebugStream
	end
	def ayadnDebugStream
		@hash = @api.getUnified(nil)
		debugStream
	end
	def ayadnDebugPost(postID)
		@hash = @api.getPostInfos("call", postID)
		debugStream
	end
	def ayadnDebugUser(username)
		@hash = @api.getUserInfos(username)
		debugStream
	end
	def ayadnDebugMessage(channel_id, message_id)
		@hash = @api.getUniqueMessage(channel_id, message_id)
		debugStream
	end
end