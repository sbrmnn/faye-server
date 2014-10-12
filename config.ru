#require './application'
#run Application.new

require 'faye'
require 'config_env'
require "rubygems"
require "bundler"

Bundler.require :default, (ENV["RACK_ENV"] || "development").to_sym
Faye::WebSocket.load_adapter('thin')
ConfigEnv.path_to_config("#{File.dirname(__FILE__)}/config/config_env.rb")

class ServerAuth
  def incoming(message, callback)
    if message['channel'] !~ %r{^/meta/}
      if message['ext'].nil? || (message['ext']['auth_token'] != ENV['faye_secret_token'])
        message['error'] = 'Invalid authentication token'
      end
    end
    callback.call(message)
  end

  def outgoing(message, callback)
    if message['ext'] && message['ext']['auth_token']
      message['ext'] = {} # IMPORTANT: clear out the auth token so it is not leaked to the client
    end
    callback.call(message)
  end
end

faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 30)
faye_server.add_extension(ServerAuth.new)
run faye_server
