class MainController < ApplicationController

include RestGraph::RailsUtil
include Date

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
  $runs = params[:runs].presence.to_i || 1
  if $runs <= 0
    $runs = 1
  end
  $magic = 23

  while @total < $runs do

    exists = false

    @bday_index = Hash.new
    @friends.sample($magic).each do |friend|
      logger.info friend['birthday']
      d = Date.parse(friend['birthday'])

      if @bday_index[d.mon] == nil
        @bday_index[d.mon] = Hash.new
      end

      if @bday_index[d.mon][d.day] == nil
        @bday_index[d.mon][d.day] = []
      else
        exists = true
      end

      @bday_index[d.mon][d.day] << friend
    end

    if exists
      @matches = @matches + 1
    end

    @total = @total + 1
  end

  session["matches"] = session["matches"] +  @matches
  session["total"] = session["total"] + @total
  @pct = session["matches"] * 100 / session["total"]

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
    rest_graph_setup(:auto_authorize => true, :scope => 'email, status_update, publish_stream, friends_birthday, offlineaccess')
end

end
