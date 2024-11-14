class HostsController < ApplicationController
  before_action :set_host, only: :events
  before_action :authenticate_user!

  def events
    @events = @host.events
  end

  private

  def set_host
    @host = User.find_by(id: params[:id])

    redirect_to root_path, alert: "Host not found" if @host.nil?
  end
end
