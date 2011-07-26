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

  def get_random_events
    
    if params[:date]
      date_get = params[:date]
      @date = Date.civil(date_get[:year].to_i,date_get[:month].to_i,date_get[:day].to_i)
    else
      @date = Date.today
    end

    nb_recs||=5

    if current_user
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => nb_recs.to_s,
        'id_user' => current_user.id.to_s
      }
    else
      arguments = {
        'date' =>@date.strftime("%Y-%m-%d"),
        'nb_recs' => nb_recs.to_s
      }
    end

    res = Net::HTTP.post_form(URI.parse('http://localhost:8080/Picalag_Pserver/API/get_recommendations_random_events'), arguments)

    puts res.body

    
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
      puts "error"
    end

    
    puts "recommendations: " + @recommendations.to_s

    render :partial => "recommendations_random_events"
  end

end
