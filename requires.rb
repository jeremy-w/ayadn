#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'open-uri'
require 'net/http'
require 'json'
require 'io/console'
require 'fileutils'
require 'yaml'
require 'pinboard'
require 'base64'
require_relative "lib/tools"
require_relative "lib/api"
require_relative "lib/view"
require_relative "lib/main"
require_relative "lib/colors"
require_relative "lib/status"
require_relative "lib/endpoints"
require_relative "lib/client-http"
winPlatforms = ['mswin', 'mingw', 'mingw_18', 'mingw_19', 'mingw_20', 'mingw32']
case Gem::Platform.local.os
when *winPlatforms
	require 'win32console'
end