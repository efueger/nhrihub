require 'authengine'
require 'rails'
require 'action_controller'
require 'application_helper'

module Authengine
  class Engine < Rails::Engine
    # Check the gem config
    initializer "check config" do |app|
      # make sure mount_at ends with trailing slash
      config.mount_at += '/'  unless config.mount_at.last == '/'
    end

    # serve static assets directly from the engine
    initializer "static assets" do |app|
      # need to move ActionDispatch::Static ahead of Rack::Sendfile as the 
      # mod_xsendfile is apparently not installed on the Apache server
      # see http://rack.rubyforge.org/doc/classes/Rack/Sendfile.html
      # this was causing blank css files to be sent.
      # 'root' here is the full path to the engine root
      #app.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

    # this causes problems in Rails5 in development environment:
    # since action_controller is not reloaded, changes to AuthenticatedSystem or AuthorizedSystem
    # cause problems and server must be restarted
    # so include these modules in ApplicationController directly
    #initializer "authengine.application_controller" do |app|
      #ActiveSupport.on_load(:action_controller) do
        #include AuthenticatedSystem
        #include AuthorizedSystem
      #end
    #end

  end
end
