# encoding: utf-8
# Store the search query that is POSTed to the URL in Rails cache and redirect to /home
# the cache key value is passed in the query string parameters

require File.expand_path('../../../config/environment',  __FILE__) unless defined?(Rails)

module Pixpalace
  class SearchStore
    def initialize(app)
      @app = app
    end
    def call(env)
      if env["PATH_INFO"] =~ %r{^/(searches|searchstat)$}
        location = path_to_location($1)
        process_request(env, location)
      else
        @app.call(env)
      end
    end

    private
    def process_request(env, location)
       req = Rack::Request.new(env)
       # params must be forced to HashWithIndifferentAccess !!
       params = HashWithIndifferentAccess.new(req.params)

       # Values must be utf-8 encoded, otherwise the search on non ascii characters will blow up !!
       params.each {|k,v| params[k.to_sym] = v.force_encoding('utf-8') if v.is_a?(String) }
       params[:providers] ||= {}

       #TODO depending of variable PATH (searches or searchstat
       params[:titles] ||= {} if location == "statistics"

       key = "#{rand(100000)}#{Time.new.to_i}"
       Rails.cache.write(key, params)

       [ 302, {'Location'=> "/#{location}?search=#{key}"}, [] ]

    end

    def path_to_location(path)
      locations = {"searches"   => "home",
             	     "searchstat" => "statistics"}
      locations[path]
    end

  end
end

