require "sinatra"
require_relative "../models/user.rb"
require "pry"

require "json"
require "net/http"
require "uri"
require "base64"

class Router < Sinatra::Base

  configure do
    enable :sessions
    set :views, "app/views"
    set :public_dir, "public"
  end

  get "/" do
    erb :index
  end

  # get "/login" do
  #   erb :login
  # end

  post "/login" do
    user = User.find_by(email: params[:email])

		if user && user.authenticate(params[:password])
	    session[:user_id] = user.id
	    redirect "/account"
	  else
	    erb :error
	  end
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do

    user = User.new(email: params[:email], password: params[:password], name: params[:name])
    if user.save
      redirect "/"
    else
      erb :error
    end
  end

  post "/playlists" do

    user = User.find(session[:user_id])
    Playlist.create(name: params[:name], user_id: user.id)
    erb :account, locals: {results: [], user: User.find(session[:user_id])}

  end

  get "/playlists/:id" do |id|

    erb :playlist

  end

  post "/playlists/:id/delete" do |id|

    playlist = Playlist.find(id)
    playlist.delete
    redirect "/account"

  end

  get "/account" do
		if logged_in?
			erb :account, locals: {results: [], user: User.find(session[:user_id])}
		else
			redirect "/"
		end
	end

  get "/logout" do
		session.clear
		redirect "/"
	end

  helpers do
      def logged_in?
  			!!session[:user_id]
  		end

  		def current_user
  			user = User.find(session[:user_id])
        user
  		end

      def set_session_token
        creds =  Base64.encode64(ENV["CLIENT_ID"]+":"+ENV["CLIENT_SECRET"]).delete("\n")
        url = URI("https://accounts.spotify.com/api/token")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(url, initheader = {"Authorization" => "Basic #{creds}"})
        request["content-type"] = 'application/x-www-form-urlencoded'
        request.body = "grant_type=client_credentials"
        response = http.request(request)
        token = JSON.parse(response.read_body)["access_token"]
        session["token"] = token
      end
  end

  post "/search" do
    # unless session.key?("token") do
      set_session_token
    # end


    terms = URI::encode(params[:search])
    url = URI("https://api.spotify.com/v1/search?q=#{terms}&type=track")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url, initheader = {"Authorization" => "Bearer #{session['token']}"})
    response = http.request(request)
    results = JSON.parse(response.body)

    onlytrackresults = results["tracks"]["items"].map{|item| item["name"]}

    erb :account, locals: {results: results}
  end

end
