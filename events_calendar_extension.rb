class EventsCalendarExtension < Radiant::Extension
  version "0.9.2"  # Compatible with Radiant 0.9
  description "Adds a calendar of events to your Radiant site."
  url "http://github.com/davec/radiant-events-calendar-extension"
  
  define_routes do |map|
    map.namespace :admin, :member => { :remove => :get, :copy => :get } do |admin|
      admin.resources :events, :collection => { :auto_complete_for_event_category => :get }
    end
    
    map.category_events '/events/:category',  :controller => 'site',
                                              :action => 'show_page',
                                              :url => 'events',
                                              :category => /(?!private-events)[a-zA-Z-]+/,
                                              :conditions => { :method => :get }

    map.event '/events/:category/:id/:name',  :controller => 'site',
                                              :action => 'show_page',
                                              :url => 'events/individual-event',
                                              :category => /[a-zA-Z-]+/,
                                              :id => /\d+/,
                                              :name => nil,
                                              :conditions => { :method => :get }

    # map.connect '/events/:id',              :controller => 'events',
    #                                         :action => 'show',
    #                                         :id => /\d+/,
    #                                         :conditions => { :method => :get }
    # 
    # map.events '/events/:year/:month/:day', :controller => 'events',
    #                                         :action => 'show',
    #                                         :year => /20\d\d/,
    #                                         :month => /(0?[1-9])|(1[0-2])/,
    #                                         :day => /(0?[1-9])|([12]\d)|(3[01])/,
    #                                         :conditions => { :method => :get }
    # 
    # map.calendar '/calendar/:year/:month',  :controller => 'calendars',
    #                                         :action => 'show',
    #                                         :year => /20\d\d/,
    #                                         :month => /(0?[1-9])|(1[0-2])/,
    #                                         :conditions => { :method => :get }
  end
  
  def activate
    tab "Content" do
      add_item "Events", "/admin/events", :after => "Pages"
    end
    Page.send :include, EventsCalendarTags
  end
  
end
