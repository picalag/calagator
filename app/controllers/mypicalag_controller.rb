require 'net/http'
require 'uri'

class MypicalagController < ApplicationController
  
  before_filter :require_user,
    :except => [:get_CB_event_events,
    :get_popular_events,
    :get_random_events,
    :get_CF_event_events,
    :get_popular_venues]

  def index
    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

  end


  def get_popular_events

    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end

    #    if current_user
    #      arguments = {
    #        'date' =>@date.strftime("%Y-%m-%d"),
    #        'nb_recs' => @nb_recs.to_s,
    #        'id_user' => current_user.id.to_s
    #      }
    #    else
    #      arguments = {
    #        'date' =>@date.strftime("%Y-%m-%d"),
    #        'nb_recs' => @nb_recs.to_s
    #      }
    #    end

    arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => @nb_recs.to_s
      }

    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_most_popular_events'), arguments)

      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//event") do |e|
          e_id = e.elements["id[1]"].text.to_i
          grade = e.elements["grade[1]"].text.to_i
          begin
            re = Event.find(e_id)
            @recommendations.push([re,grade])
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_popular_events"
  end

  def get_random_events
    
    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end

    if current_user
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => @nb_recs.to_s,
        'id_user' => current_user.id.to_s
      }
    else
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => @nb_recs.to_s
      }
    end

    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_random_events'), arguments)
    
      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//event") do |e|
          e_id = e.elements["id[1]"].text.to_i
          begin
            re = Event.find(e_id)
            @recommendations.push(re)
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_random_events"
  end

  def get_CB_user_events

    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end

    if current_user
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => @nb_recs.to_s,
        'id_user' => current_user.id.to_s
      }
    else
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => @nb_recs.to_s
      }
    end

    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_CB_user'), arguments)

      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//event") do |e|
          e_id = e.elements["id[1]"].text.to_i
          distance = e.elements["distance[1]"].text.to_f
          distance = (distance*100.0)
          distance = distance.round
          begin
            re = Event.find(e_id)
            @recommendations.push([re,distance])
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_CB_user_events"
  end

  def get_CF_user_events

    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end

    if current_user
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => @nb_recs.to_s,
        'id_user' => current_user.id.to_s
      }
    else
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => @nb_recs.to_s
      }
    end

    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_CF_user'), arguments)

      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//event") do |e|
          e_id = e.elements["id[1]"].text.to_i
          grade = 0.0
          nb_r = 0
          e.each_element("neighbour_rating") do |r|
            grade = grade + r.text.to_i
            nb_r = nb_r + 1
          end
          grade = grade.to_f / nb_r.to_f
          grade = grade.round(2)
          begin
            re = Event.find(e_id)
            @recommendations.push([re,grade])
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_CF_user_events"
  end

  def is_favorite_venue

    @is_fav = "error"
    
    if params[:id]
      if current_user
        arguments = {
          'id_venue' => params[:id].to_s,
          'id_user' => current_user.id.to_s
        }

        @id_venue = params[:id].to_i


        begin

          if params[:change]
            if params[:change].to_s == "add"
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/add_venue_to_favorite'), arguments)
            elsif params[:change].to_s == "del"
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/del_venue_from_favorite'), arguments)
            end
          end

          res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/is_favorite_venue'), arguments)

          case res
          when Net::HTTPSuccess
            @is_fav = res.body.to_s
          else
            @is_fav = "error"
          end

        rescue Errno::ECONNREFUSED => e
          # no connection with the server
          @is_fav = "error"
        end

      end
    end
    @is_fav = @is_fav.strip

    render :partial => "add_remove_favorite_venue"
  end

  def get_rating

    @r = "error"

    if params[:id]
      if current_user
        if params[:rate]
          arguments = {
            'id_event' => params[:id].to_s,
            'id_user' => current_user.id.to_s,
            'rating' => params[:rate].to_s
          }
        else
          arguments = {
            'id_event' => params[:id].to_s,
            'id_user' => current_user.id.to_s
          }
        end



        begin

          if params[:rate]
            if params[:rate].to_s == "liked" || 
                params[:rate].to_s == "neutral" ||
                params[:rate].to_s == "viewed" ||
                params[:rate].to_s == "shared" ||
                params[:rate].to_s == "added"
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/rate_event'), arguments)
              # if user rates an event it's just like if he goes to the page again
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/view_event'), arguments)
            else params[:rate].to_s == "disliked"
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/never_again'), arguments)
            end
          end

          res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_rating'), arguments)

          case res
          when Net::HTTPSuccess
            @r = res.body.to_s.strip
            begin
              # try to parse to integer
              @r = Integer(@r)
            rescue ArgumentError => e
              @r = "error"
            end
          else
            @r = "error"
          end

        rescue Errno::ECONNREFUSED => e
          # no connection with the server
          @r = "error"
        end

      end
    end
    

    render :partial => "get_rating"
  end


  def get_CB_event_events

    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end

    # just in case
    @recommendations="error"

    @id_event
    
    if params[:id_event]
      @id_event = params[:id_event]
    end

    arguments = {
      'date' =>@date.strftime("%Y-%m-%d"),
      'nb_recs' => @nb_recs.to_s,
      'id_event' => @id_event.to_s
    }


    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_CB_event'), arguments)

      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//event") do |e|
          e_id = e.elements["id[1]"].text.to_i
          distance = e.elements["distance[1]"].text.to_f
          distance = (distance*100.0)
          distance = distance.round
          begin
            re = Event.find(e_id)
            @recommendations.push([re,distance])
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_CB_event_events"
  end


  def get_CF_event_events

    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end

    # just in case
    @recommendations="error"

    @id_event

    if params[:id_event]
      @id_event = params[:id_event]
    end

    arguments = {
      'date' =>@date.strftime("%Y-%m-%d"),
      'nb_recs' => @nb_recs.to_s,
      'id_event' => @id_event.to_s
    }


    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_CF_event'), arguments)

      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//event") do |e|
          e_id = e.elements["id[1]"].text.to_i
          distance = e.elements["distance[1]"].text.to_f
          distance = (distance*100.0)
          distance = distance.round
          begin
            re = Event.find(e_id)
            @recommendations.push([re,distance])
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_CF_event_events"
  end

  def favorite_venues

    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    
    arguments = { 'id_user' => current_user.id.to_s }
    @venues = []
    
    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_favorite_venues'), arguments)

      case res
      when Net::HTTPSuccess
        @venues = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//venue") do |e|
          v_id = e.text.to_i
          begin
            fv = Venue.find(v_id)
            events = Event.find_by_dates(@date, @date, :venue => fv)
            @venues.push([fv,events])
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @venues = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @venues = "error"
    end

    
  end

  def get_popular_venues

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end


#    if current_user
#      arguments = { 'nb_recs' => @nb_recs.to_s, 'id_user' => current_user.id.to_s }
#    else
#      arguments = { 'nb_recs' => @nb_recs.to_s }
#    end

    arguments = { 'nb_recs' => @nb_recs.to_s }

    @recommendation = "error"
    
    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_most_popular_venues'), arguments)

      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//venue") do |e|
          v_id = e.elements["id[1]"].text.to_i
          fans = e.elements["fans[1]"].text.to_i

          begin
            rv = Venue.find(v_id)
            @recommendations.push([rv,fans])
          rescue ActiveRecord::RecordNotFound => e
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_popular_venues"

  end

  def get_rec_venues

    @nb_recs = 5

    if params[:nb_recs]
      @nb_recs = params[:nb_recs].to_i
    end

    arguments = { 'nb_recs' => @nb_recs.to_s, 'id_user' => current_user.id.to_s }

    @recommendation = "error"

    begin
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/get_recommendations_venues'), arguments)

      case res
      when Net::HTTPSuccess
        @recommendations = []
        xml = REXML::Document.new res.body

        xml.root.each_element("//venue") do |e|
          v_id = e.elements["id[1]"].text.to_i

          begin
            rv = Venue.find(v_id)
            similar = []

            e.each_element("similar") do |s|
              begin
                sv = Venue.find(s.text.to_i)
                similar.push(sv)
              rescue ActiveRecord::RecordNotFound => ex
                # do nothing
              end
            end

            @recommendations.push([rv,similar])
          rescue ActiveRecord::RecordNotFound => ex
            # do nothing
          end
        end
      else
        @recommendations = "error"
      end
    rescue Errno::ECONNREFUSED => e
      # no connection with the server
      @recommendations = "error"
    end

    render :partial => "recommendations_venues"

  end

end
