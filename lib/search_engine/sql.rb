require 'lib/search_engine/base'

class SearchEngine::Sql < SearchEngine::Base
  score false

  def self.add_searching_to(model)
    case model.new
    when Venue, Source
      # Do nothing
    when Event
      model.class_eval do
        # Return an Array of non-duplicate Event instances matching the search +query+..
        #
        # Options:
        # * :order => How to order the entries? Defaults to :date. Permitted values:
        #   * :date => Sort by date
        #   * :name => Sort by event title
        #   * :title => same as :name
        #   * :venue => Sort by venue title
        # * :limit => Maximum number of entries to return. Defaults to +solr_search_matches+.
        # * :skip_old => Return old entries? Defaults to false.
        def self.search(query, opts={})
          skip_old = opts[:skip_old] == true
          limit = opts[:limit] || 50
          

          order = \
            case opts[:order].try(:to_sym)
            when nil, '', :date, :score
              'events.start_time DESC'
            when :name, :title
              'LOWER(events.title) ASC'
            when :location, :venue
              'LOWER(venues.title) ASC'
            else
              raise ArgumentError, "Unknown order: #{order}"
            end

          conditions_text = ''
          conditions_arguments = []
          query.scan(/\w+/).each do |keyword|
            like = "%#{keyword.downcase}%"
            conditions_text << ' OR ' if conditions_text.present?
            conditions_text << 'LOWER(events.title) LIKE ? OR LOWER(events.description) LIKE ? OR LOWER(events.url) LIKE ? OR LOWER(tags.name) = ?'
            conditions_arguments += [like, like, like, keyword]
          end
          if skip_old
            conditions_text = "events.start_time >= ? AND (#{conditions_text})"
            conditions_arguments = [Date.yesterday.to_time] + conditions_arguments
          end
          if(opts[:date])
            conditions_text = "events.start_time >= ? AND events.end_time <= ? AND (#{conditions_text})"
            conditions_arguments = [(opts[:date].to_time - 1.hour).to_time, (opts[:date]+1.day).to_time] + conditions_arguments
          end
          if(opts[:start_date] && opts[:end_date])
            conditions_text = "events.start_time >= ? AND events.end_time <= ? AND (#{conditions_text})"
            conditions_arguments = [(opts[:start_date].to_time - 1.hour).to_time, (opts[:end_date]+1.day).to_time] + conditions_arguments
          end

          conditions = [conditions_text, *conditions_arguments]
          return Event.all(:conditions => conditions, :order => order, :limit => limit, :include => [:venue, :taggings, :tags])
        end
      end
    else
      raise TypeError, "Unknown model class: #{model.name}"
    end
  end
end
