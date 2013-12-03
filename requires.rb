#!/usr/bin/ruby
# encoding: utf-8
require 'rubygems'
require 'uri'
require 'net/http'
require 'rest_client'
require 'json'
require 'io/console'
require 'fileutils'
require 'yaml'
require_relative "lib/lib-tools"
require_relative "lib/lib-api"
require_relative "lib/lib-view"
require_relative "lib/lib-main"
require_relative "lib/colors"
require_relative "lib/status"
winPlatforms = ['mswin', 'mingw', 'mingw_18', 'mingw_19', 'mingw_20', 'mingw32']
case Gem::Platform.local.os
when *winPlatforms
	require 'win32console'
end