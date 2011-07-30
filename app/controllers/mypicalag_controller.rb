require 'net/http'
require 'uri'

class MypicalagController < ApplicationController
  
  before_filter :require_user


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
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs2'), arguments)

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
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs'), arguments)
    
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
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs3'), arguments)

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
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs4'), arguments)

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
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs6'), arguments)
            elsif params[:change].to_s == "del"
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs7'), arguments)
            end
          end

          res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs5'), arguments)

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
            if params[:rate].to_s == "liked" || params[:rate].to_s == "neutral" || params[:rate].to_s == "disliked"
              res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs9'), arguments)
            end
          end

          res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs8'), arguments)

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
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs3'), arguments)

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
      res = Net::HTTP.post_form(URI.parse(SETTINGS.pserver + '/test_recs3'), arguments)

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


end
