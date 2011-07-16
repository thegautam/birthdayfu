require 'rubygems'
require 'sinatra'
require 'omniauth/oauth'

enable :sessions

APP_ID = "148825938527739"
APP_SECRET = "2e6a5458f3abb2038088108ecf995eb6"

use Rack::Session::Cookie

use OmniAuth::Builder do
  provider :facebook, APP_ID, APP_SECRET,
  { :scope => 'email, status_update, publish_stream, friends_birthday, offline_access' }
end

get '/' do
    erb :index
end

post '/' do
    erb :index
end

get '/auth/facebook/callback' do
  session['fb_auth'] = request.env['omniauth.auth']
  session['fb_token'] = session['fb_auth']['credentials']['token']
  session['fb_error'] = nil
  redirect '/'
end

get '/auth/failure' do
  clear_session
  session['fb_error'] = 'In order to use this site you must allow us access to
  your Facebook data<br />'
  redirect '/'
end

get '/logout' do
  clear_session
  redirect '/'
end

def clear_session
  session['fb_auth'] = nil
  session['fb_token'] = nil
  session['fb_error'] = nil
end
