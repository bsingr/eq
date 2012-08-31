require 'sinatra'

module EQ::Web
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/views"

    get '/' do
      erb :index
    end
  end
end
