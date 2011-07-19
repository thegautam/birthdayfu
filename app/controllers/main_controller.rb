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
  $runs = params[:runs].presence.to_i || 1
  $runs = $runs <= 0 ? 1 : $runs
  $runs = $runs > 100 ? 100 : $runs
  $magic = 23

  while @total < $runs do

    exists = false

    @bday_index = Hash.new
    @friends.sample($magic).each do |friend|
      d = Date.strptime(friend['birthday'], '%m/%d') rescue Date.strptime(friend['birthday'], '%m/%d/%Y')

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

  session["matches"] = (session["matches"].presence || 0) +  @matches
  session["total"] = (session["total"].presence || 0) + @total
  @pct = session["matches"] * 100 / session["total"]

  render :action => 'paradox'
end

private

def get_friends
  logger.info rest_graph.get('me')['name'] + " ran a test."
  @friends = rest_graph.get('me/friends', {'fields' => 'name, birthday, link, picture'})['data'] \
    .find_all {|f| not f['birthday'] == nil}
  params.delete(:code)
end

def date_consts
  # Jan, Feb ... Dec
  @months = [].fill(0,12) { |i| i+1 }
  # 1, 2 ... 31
  @days = [].fill(0,31) { |i| i+1 }
end

def filter_setup_rest_graph
  if not request.host.downcase.end_with? 'conaytus.com'
    redirect_to 'http://birthdayfu.conaytus.com'
  end
  rest_graph_setup(:write_session => true, :auto_authorize => true, :auto_authorize_scope => 'friends_birthday')
end

end
