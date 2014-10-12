require "rubygems"
require "bundler"
Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym

Dir[File.dirname(__FILE__) + "/config/*.rb"].each { |file| require file }

ConfigEnv.path_to_config("#{File.dirname(__FILE__)}/config/config_env.rb")