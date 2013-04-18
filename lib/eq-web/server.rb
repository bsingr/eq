require 'sinatra'

module EQ::Web
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))
    set :views,  "#{dir}/views"

    get '/' do
      erb :index
    end

    get '/delete' do
      EQ.queue.clear
    end

    get '/delete/:id' do
      EQ.queue.pop(params[:id])
      redirect url_path
    end

    get '/retry/:id' do
      EQ.queue.retry(params[:id])
      redirect url_path
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def current_page
        url_path request.path_info.sub('/','')
      end

      def url_path(*path_parts)
        [ path_prefix, path_parts ].join("/").squeeze('/')
      end
      alias_method :u, :url_path

      def path_prefix
        request.env['SCRIPT_NAME']
      end
    end
  end
end
