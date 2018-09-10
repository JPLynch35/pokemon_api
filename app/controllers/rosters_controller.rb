class RostersController < ApplicationController
  def create
    @roster = RosterBase.create(name: params["name"])
  end
end
