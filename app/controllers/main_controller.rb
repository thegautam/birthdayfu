class MainController < ApplicationController

include RestGraph::RailsUtil

before_filter :filter_setup_rest_graph
before_filter :get_friends, :only => [:friends, :paradox]

def me
  render :text => rest_graph.get('?batch=[{"method":"GET", "relative_url":"me"}]').inspect
end

def friends
  render :action => 'friends'
end

def paradox
  @matches = 0
  @total = 0

  while @total < 100 do
    @dated_friends = []
    @bday_hashes = Hash.new
    @exists = false
    @friends.sample(23).each do |friend|
      date = Date.parse(friend['birthday'])
      friend['bday'] = date
      @dated_friends << friend

      key = "#{date.day}/#{date.mon}"
      if @bday_hashes.key?(key)
        @bday_hashes[key] << ", #{friend['name']}"
        @exists = true
      else
        @bday_hashes[key] = friend['name']
      end
    end
    if @exists
      @matches = @matches + 1
    end
    @total = @total + 1
  end

  render :action => 'paradox'
end

private

def get_friends
  @friends = rest_graph.get('me/friends', {'fields' => 'name, birthday'})['data'] \
    .find_all {|f| not f['birthday'] == nil}
end

def filter_setup_rest_graph
    rest_graph_setup(:auto_authorize => true)
end

end
