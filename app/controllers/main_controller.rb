class MainController < ApplicationController

include RestGraph::RailsUtil

before_filter :filter_setup_rest_graph
before_filter :get_friends, :only => [:friends, :paradox]
before_filter :date_consts, :only => [:paradox]

def me
  render :text => rest_graph.get('?batch=[{"method":"GET", "relative_url":"me"}]').inspect
end

def friends
  render :action => 'friends'
end

def paradox
  @matches = 0
  @total = 0
  $runs = 1
  $magic = 23

  while @total < $runs do

    exists = false

    @bday_index = Hash.new
    @friends.sample($magic).each do |friend|
      date = Date.parse(friend['birthday'])
      key = "#{date.mon}-#{date.day}"
      if @bday_index[key] == nil
        @bday_index[key] = []
      else
        exists = true
      end

      @bday_index[key] << friend
    end

    if exists
      @matches = @matches + 1
    end

    @total = @total + 1
  end

  render :action => 'paradox'
end

private

def get_friends
  @friends = rest_graph.get('me/friends', {'fields' => 'name, birthday, link, picture'})['data'] \
    .find_all {|f| not f['birthday'] == nil}
end

def date_consts
  # Jan, Feb ... Dec
  @months = [].fill(0,12) { |i| i+1 }
  # 1, 2 ... 31
  @days = [].fill(0,31) { |i| i+1 }
end

def filter_setup_rest_graph
    rest_graph_setup(:auto_authorize => true)
end

end
