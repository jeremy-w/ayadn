#!/usr/bin/env ruby
# encoding: utf-8

%w{rubygems pstore date open-uri net/http json io/console fileutils yaml pinboard base64}.each do |r|
  require "#{r}"
end

winPlatforms = ['mswin', 'mingw', 'mingw_18', 'mingw_19', 'mingw_20', 'mingw32']
case Gem::Platform.local.os
when *winPlatforms
	require 'win32console'
end
