class EventsController < ApplicationController
  radiant_layout 'Events'
  no_login_required

  skip_before_filter :verify_authenticity_token
  before_filter :find_page

  ##
  # WE ARE NOT USING THIS
  ##
  
  def show
    if (params[:id])
      @event = Event.find(params[:id])
    else
      # @date = Date.civil(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      # @events = Event.for_date(@date) if @date
      # @category = params[:category]
      # @events = Event.find_all_by_category(@category) if @category
      
      # @page.events = @events
      # @page.process(request, response)
      # @performed_render = true
    end
  end

  private
  
    def find_page
      # url = params[:url]
      # url.shift if defined?(SiteLanguage) && SiteLanguage.count > 1
      # @page = Page.find_by_url('/events')
    end
    
end
