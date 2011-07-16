class MainController < ApplicationController

include RestGraph::RailsUtil

before_filter :filter_setup_rest_graph

def me
    render :text => rest_graph.get('me').inspect
end

def friends
  @friends = []
  friends_bare = rest_graph.get('me/friends')['data']
  friends_bare.each do |friend_bare|
    @friends << rest_graph.get(friend_bare['id'])
  end

  render :action => 'friends'
end

private

def filter_setup_rest_graph
    rest_graph_setup(:auto_authorize => true)
end

end
