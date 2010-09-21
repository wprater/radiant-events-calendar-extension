module EventsCalendarTags
  include Radiant::Taggable
  include CalendarsHelper
  
  # include ActionController::UrlWriter
  
  # def base_gallery_id
  #   event = Event.find(@request.params[:id])
  #   event.base_gallery_id
  # end
  
  class TagError < StandardError ; end

  tag 'event' do |tag|
    event = Event.find(@request.params[:id])
    tag.locals.event = event
    tag.locals.page.title = event.name
    tag.locals.gallery ||= Gallery.find_by_id(event.base_gallery_id)
    tag.expand
  end
  
  desc %{
    Gives access to all events, sorted by start_time by default.

    The `for` attribute can be any of the following:
    * "today"
    * "tomorrow"
    * "yesterday"
    * a date in this format: "YYYY-MM-DD" (ex: 2009-03-14)
    * a specified number of days, weeks, months, or years either in the future or past (e.g., "next 2 weeks", "previous 7 days")

    The `inclusive` attribute applies to relative `for` values. If set to `true` (the default) then `today` is included; otherwise `today` is excluded.

    <pre><code><r:events [for="date" [inclusive="true|false"]] [by="attribute"] [order="asc|desc"] [limit="number"] [offset="number"]/></code></pre>
  }
  tag 'events' do |tag|
    filter_category = @request.params[:category]
    # Show all events when on upcoming-events
    if filter_category and 'upcoming-events' != filter_category
      tag.attr['category'] = filter_category
      # Set the title from the stub page with same category name
      tag.globals.page.title = Page.find_by_url("#{@request.params[:url]}/#{filter_category}").title + " Events"
    end
    tag.locals.events = Event.all(events_find_options(tag))
    tag.expand
  end

  desc %{
    Loops through events.
  }
  tag 'events:each' do |tag|
    tag.locals.previous_headers = {}
    tag.locals.events.collect do |event|
      tag.locals.event = event
      tag.expand
    end
  end
  
  
  tag 'events:each:header' do |tag|
    previous_headers = tag.locals.previous_headers || {}
    name = tag.attr['name'] || :unnamed
    restart = (tag.attr['restart'] || '').split(';')
    header = tag.expand
    unless header == previous_headers[name]
      previous_headers[name] = header
      unless restart.empty?
        restart.each do |n|
          previous_headers[n] = nil
        end
      end
      header
    end
  end
 
  desc %{
    Creates the context for a single event.
  }
  tag 'events:each:event' do |tag|
    tag.expand
  end

  desc %{
    Renders the location for the current event.
  }
  tag 'event:link' do |tag|
    options = tag.attr.dup
    base_url = options.delete('base_url')
    event = tag.locals.event

    url = base_url.nil? ? tag.render('url') : base_url
    #url = tag.render('url')

    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : event.name
    %{<a href="#{url}#{event.category}/#{event.id}#{anchor}"#{attributes}>#{text}</a>}
    # event_link(event)
  end

  desc %{
    Renders the name for the current event.
  }
  tag 'event:name' do |tag|
    event = tag.locals.event
    event.name
  end

  desc %{
    Renders the date for the current event.
    An optional date format string may be specified.
    The default format string is <code>%Y-%m-%d</code>.

    *Usage:*
    <pre><code><r:event:date /></code></pre>
    <pre><code><r:event:date format='%d %b %Y' /></code></pre>
  }
  tag 'event:date' do |tag|
    event = tag.locals.event
    format = tag.attr['format'] || '%Y-%m-%d'
    event.date.strftime(format)
  end

  desc %{
    Renders the time for the current event.
    An optional time format string and time connector, for time ranges, may be specified.
    The default format string is <code>%H:%M</code> and the default connector is <code>-</code> (hyphen).
    The time connector is only used when an event has both a start time and an end time.

    *Usage:*
    <pre><code><r:event:time /></code></pre>
    <pre><code><r:event:time format='%I:%M %p' connector='to' /></code></pre>
  }
  tag 'event:time' do |tag|
    event = tag.locals.event
    return '' unless event.start_time

    format = tag.attr['format'] || '%H:%M'
    times = [ event.start_time.strftime(format).gsub(/^0/,'').downcase, 
              event.end_time ? event.end_time.strftime(format).gsub(/^0/,'').downcase : nil ]
    times.compact.join(" #{tag.attr['connector'] || '-'} ")
  end

  desc %{
    Renders the location for the current event.
  }
  tag 'event:location' do |tag|
    event = tag.locals.event
    event.location
  end

  desc %{
    Renders the description for the current event.
  }
  tag 'event:description' do |tag|
    event = tag.locals.event
    event.description_html
  end

  desc %{
    Renders the short description for the current event.
  }
  tag 'event:description:short' do |tag|
    event = tag.locals.event
    event.short_description
  end

  desc %{
    Renders the category for the current event.
  }
  tag 'event:category' do |tag|
    event = tag.locals.event
    event.category
  end
  
  %w[price reservation_details website].each do |method|
    desc %{
      Renders the #{method} for the current event.
    }
    tag "event:#{method}" do |tag|
      event = tag.locals.event
      event.send(method)
    end
    desc %{
      Renders if the #{method} for the current event exists.
    }
    tag "event:if_#{method}" do |tag|
      event = tag.locals.event
      tag.expand if event.send(method)
    end
    desc %{
      Renders unless the #{method} for the current event exists.
    }
    tag "event:unless_#{method}" do |tag|
      event = tag.locals.event
      tag.expand unless event.send(method)
    end
  end

  # desc %{
  #   Renders the price for the current event.
  # }
  # tag 'event:price' do |tag|
  #   event = tag.locals.event
  #   event.price
  # end
  # 
  # desc %{
  #   Renders the category for the current event.
  # }
  # tag 'event:reservation_details' do |tag|
  #   event = tag.locals.event
  #   event.reservation_details
  # end
  # 
  # desc %{
  #   Renders the website for the current event.
  # }
  # tag 'event:website' do |tag|
  #   event = tag.locals.event
  #   event.website
  # end

  desc %{
    Creates a calendar for the given month.
    If no date is given, the current month is used.

    *Usage:*
    <pre><code><r:calendar /></code></pre>
    <pre><code><r:calendar year='2009' month='1' /></code></pre>
  }
  tag 'calendar' do |tag|
    options = [ tag.attr['year'], tag.attr['month'] ].compact
    raise TagError, "the calendar tag requires a month and year to be specified" unless options.empty? || options.length == 2

    # If the JavaScript is not enabled in the client, CalendarsController#show stores the calendar dates in the session
    stored_calendar_view = request.session[:calendar_view] || {}

    year  = tag.attr['year']  || stored_calendar_view[:year]  || Date.today.year
    month = tag.attr['month'] || stored_calendar_view[:month] || Date.today.month

    request.session.delete(:calendar_view)

    date = Date.civil(year.to_i, month.to_i)
    make_calendar(date)
  end

  private
    def events_find_options(tag)
      attr = tag.attr.symbolize_keys

      options = {}
      where_clauses = []
      where_values = []

      [:limit, :offset].each do |symbol|
        if number = attr[symbol]
          if number =~ /^\d{1,4}$/
            options[symbol] = number.to_i
          else
            raise TagError.new("`#{symbol}' attribute of `each' tag must be a positive number between 1 and 4 digits")
          end
        end
      end

      by = (attr[:by] || 'start_time').strip
      order = (attr[:order] || 'asc').strip
      order_string = ""
      if Event.column_names.include?(by)
        order_string << by
      else
        raise TagError.new("`by' attribute of `each' tag must be set to a valid field name")
      end
      if order =~ /^(asc|desc)$/i
        order_string << " #{$1.upcase}"
      else
        raise TagError.new(%{`order' attribute of `each' tag must be set to either "asc" or "desc"})
      end
      options[:order] = order_string

      if attr[:for]
        if attr[:for] =~ /\A(next|previous)\s+(\d+)\s+(day|week|month|year)s?\z/
          direction, count, interval = $1, $2.to_i, $3
          include_today = (attr[:inclusive] || "true") == "true"
          if direction == "next"
            start_date = include_today ? Date.today : Date.today + 1
            end_date = Date.today + count.send(interval)
          else
            start_date = Date.today - count.send(interval)
            end_date = include_today ? Date.today : Date.today - 1
          end

          where_clauses << "date >= ?" << "date <= ?"
          where_values << start_date << end_date
        else
          date = case attr[:for]
                 when "today"
                   Date.today
                 when "yesterday"
                   Date.today - 1
                 when "tomorrow"
                   Date.today + 1
                 else
                   parts = attr[:for].split("-")
                   raise TagError, "invalid date" unless parts.length == 3
                   Date.civil(*parts.collect(&:to_i))
                 end

          where_clauses << "date = ?"
          where_values  << date
        end
      end

      if attr[:category]
        where_clauses << "category = ?"
        where_values  << attr[:category]
      end

      if !where_clauses.empty?
        options[:conditions] = [where_clauses.join(" AND ")] + where_values
      end

      options
    end
end
