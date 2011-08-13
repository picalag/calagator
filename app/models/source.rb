# == Schema Information
# Schema version: 20110604174521
#
# Table name: sources
#
#  id          :integer         not null, primary key
#  title       :string(255)     
#  url         :string(255)     
#  imported_at :datetime        
#  created_at  :datetime        
#  updated_at  :datetime        
#  reimport    :boolean         
#

# == Source
#
# A model that represents a source of events data, such as feeds for hCal, iCal, etc.
class Source < ActiveRecord::Base
  include SearchEngine

  validate :assert_url

  has_many :events,  :dependent => :destroy
  has_many :venues,  :dependent => :destroy
  has_many :updates, :dependent => :destroy

  named_scope :listing, :order => 'created_at DESC'

  has_paper_trail

  STOP_WORDS = "a|able|about|above|abst|accordance|according|accordingly|across|act|actually|added|adj|adopted|affected|affecting|affects|after|afterwards|again|against|ah|all|almost|alone|along|already|also|although|always|am|among|amongst|an|and|announce|another|any|anybody|anyhow|anymore|anyone|anything|anyway|anyways|anywhere|apparently|approximately|are|aren|arent|arise|around|as|aside|ask|asking|at|auth|available|away|awfully|b|back|be|became|because|become|becomes|becoming|been|before|beforehand|begin|beginning|beginnings|begins|behind|being|believe|below|beside|besides|between|beyond|biol|both|brief|briefly|but|by|c|ca|came|can|cannot|can't|cause|causes|certain|certainly|co|com|come|comes|contain|containing|contains|could|couldnt|d|date|did|didn't|different|do|does|doesn't|doing|done|don't|down|downwards|due|during|e|each|ed|edu|effect|eg|eight|eighty|either|else|elsewhere|end|ending|enough|especially|et|et-al|etc|even|ever|every|everybody|everyone|everything|everywhere|ex|except|f|far|few|ff|fifth|first|five|fix|followed|following|follows|for|former|formerly|forth|found|four|from|further|furthermore|g|gave|get|gets|getting|give|given|gives|giving|go|goes|gone|got|gotten|h|had|happens|hardly|has|hasn't|have|haven't|having|he|hed|hence|her|here|hereafter|hereby|herein|heres|hereupon|hers|herself|hes|hi|hid|him|himself|his|hither|home|how|howbeit|however|hundred|i|id|ie|if|i'll|im|immediate|immediately|importance|important|in|inc|indeed|index|information|instead|into|invention|inward|is|isn't|it|itd|it'll|its|itself|i've|j|just|k|keep|	keeps|kept|keys|kg|km|know|known|knows|l|largely|last|lately|later|latter|latterly|least|less|lest|let|lets|like|liked|likely|line|little|'ll|look|looking|looks|ltd|m|made|mainly|make|makes|many|may|maybe|me|mean|means|meantime|meanwhile|merely|mg|might|million|miss|ml|more|moreover|most|mostly|mr|mrs|much|mug|must|my|myself|n|na|name|namely|nay|nd|near|nearly|necessarily|necessary|need|needs|neither|never|nevertheless|new|next|nine|ninety|no|nobody|non|none|nonetheless|noone|nor|normally|nos|not|noted|nothing|now|nowhere|o|obtain|obtained|obviously|of|off|often|oh|ok|okay|old|omitted|on|once|one|ones|only|onto|or|ord|other|others|otherwise|ought|our|ours|ourselves|out|outside|over|overall|owing|own|p|page|pages|part|particular|particularly|past|per|perhaps|placed|please|plus|poorly|possible|possibly|potentially|pp|predominantly|present|previously|primarily|probably|promptly|proud|provides|put|q|que|quickly|quite|qv|r|ran|rather|rd|re|readily|really|recent|recently|ref|refs|regarding|regardless|regards|related|relatively|research|respectively|resulted|resulting|results|right|run|s|said|same|saw|say|saying|says|sec|section|see|seeing|seem|seemed|seeming|seems|seen|self|selves|sent|seven|several|shall|she|shed|she'll|shes|should|shouldn't|show|showed|shown|showns|shows|significant|significantly|similar|similarly|since|six|slightly|so|some|somebody|somehow|someone|somethan|something|sometime|sometimes|somewhat|somewhere|soon|sorry|specifically|specified|specify|specifying|state|states|still|stop|strongly|sub|substantially|successfully|such|sufficiently|suggest|sup|sure|	t|take|taken|taking|tell|tends|th|than|thank|thanks|thanx|that|that'll|thats|that've|the|their|theirs|them|themselves|then|thence|there|thereafter|thereby|thered|therefore|therein|there'll|thereof|therere|theres|thereto|thereupon|there've|these|they|theyd|they'll|theyre|they've|think|this|those|thou|though|thoughh|thousand|throug|through|throughout|thru|thus|til|tip|to|together|too|took|toward|towards|tried|tries|truly|try|trying|ts|twice|two|u|un|under|unfortunately|unless|unlike|unlikely|until|unto|up|upon|ups|us|use|used|useful|usefully|usefulness|uses|using|usually|v|value|various|'ve|very|via|viz|vol|vols|vs|w|want|wants|was|wasn't|way|we|wed|welcome|we'll|went|were|weren't|we've|what|whatever|what'll|whats|when|whence|whenever|where|whereafter|whereas|whereby|wherein|wheres|whereupon|wherever|whether|which|while|whim|whither|who|whod|whoever|whole|who'll|whom|whomever|whos|whose|why|widely|willing|wish|with|within|without|won't|words|world|would|wouldn't|www|x|y|yes|yet|you|youd|you'll|your|youre|yours|yourself|yourselves|you've|z|zero"

  # Return a newly-created or existing Source record matching the given
  # attributes. The +attrs+ hash is the same format as used when calling
  # Source::new.
  #
  # This method is intended to supplement the import process by providing a
  # single Source record for each unique URL, thus when multiple people import
  # the same URL, there will only be one Source record.
  #
  # The :reimport flag is given special handling: If the original Source record
  # has this set to true, it will never be set back to false by this method.
  # The intent behind this is that if one person wants this Source reimported,
  # the reimporting shouldn't be disabled by someone else manually importing it
  # without setting the reimport flag. If someone really wants to turn off
  # reimporting, they should edit the source.
  def self.find_or_create_from(attrs={})
    if attrs && attrs[:url]
      source = Source.find_or_create_by_url(attrs[:url])
      attrs.each_pair do |key, value|
        if key.to_sym == :reimport
          source.reimport = true if ! source.reimport && value
        else
          source.send("#{key}=", value) if source.send(key) != value
        end
      end
      source.save if source.changed?
      return source
    else
      return Source.new(attrs)
    end
  end

  # Create events for this source. Returns the events created. URL must be set
  # for this source for this to work.
  def create_events!(opts={})
    cutoff = Time.now.yesterday # All events before this date will be skipped
    events = []
    for event in self.to_events(opts)
      if opts[:skip_old]
        next if event.title.blank? && event.description.blank? && event.url.blank?
        next if event.old?
      end

      # Skip invalid events that start after they end
      next if event.end_time && event.end_time < event.start_time

      # convert to local time, because time zone is simply discarded when event is saved
      event.start_time.localtime
      event.end_time.localtime if event.end_time

      # clear duplicate_of_id field in case to_events picked up orphaned duplicate
      # TODO clear the duplicate_of_id at the point where the object is created, not down here
      event.duplicate_of_id = nil if event.duplicate_of_id
      event.save!
      if event.venue
        event.venue.duplicate_of_id = nil if event.venue.duplicate_of_id
        event.venue.save! if event.venue
      end
      events << event
    end
    self.save!
    return events
  end

  # Normalize the URL.
  def url=(value)
    begin
      url = URI.parse(value.strip)
      url.scheme = 'http' unless ['http','https','ftp'].include?(url.scheme) || url.scheme.nil?
      write_attribute(:url, url.scheme.nil? ? 'http://'+value.strip : url.to_s)
    rescue URI::InvalidURIError => e
      false
    end
  end

  # Returns an Array of Event objects that were read from this source.
  #
  # Options:
  # * :url -- URL of data to import. Defaults to record's #url attribute.
  # * :skip_old -- Should old events be skipped? Default is true.
  def to_events(opts={})
    self.imported_at = Time.now
    if valid?
      opts[:url] ||= self.url
      [].tap do |events|
        SourceParser.to_abstract_events(opts).each do |abstract_event|
          event = Event.from_abstract_event(abstract_event, self)

          events << event
        end
      end
    else
      raise ActiveRecord::RecordInvalid, self
    end
  end

  # Return the name of the source, which can be its title or URL.
  def name
    [title,url].detect{|t| !t.blank?}
  end
  
  
  # API_import_event! extracts info from table and create event and venue for this source
  #
  # Options:
  # * :Id -- ID scraping
  # * :Title -- Event title
  # * :Id_event -- Event ID on source website
  # * :Link -- URL to Event page (Source URL)
  # * :Description -- Event description text
  # * :Start -- Event start
  # * :End -- Event end
  # * :Category -- Event category
  #
  # * :Venue -- Venue name
  # * :VenueInfo -- Venue info
  # * :Tel -- Venue Tel number
  # * :Address -- Venue address
  # * :Longitude -- Venue longitude
  # * :Latitude -- Venue latitude
  # * :LinkVenue -- URL to Venue page
  def API_import_event!(opts={})
    self.url = opts[:Link]
    self.title = opts[:Link]
	
    venue = Venue.find_or_create_by_url(opts[:LinkVenue])
    venue.title = opts[:Venue]
    venue.description = opts[:VenueInfo]
    venue.address = opts[:Address]
    venue.telephone = opts[:Tel]
    venue.latitude = opts[:Latitude]
    venue.longitude = opts[:Longitude]
	
    event = Event.find_or_create_by_url(opts[:Link])
    event.venue = venue
    event.url = opts[:Link]
    event.title = opts[:Title]
    event.description = opts[:Description]
    event.start_time = opts[:Start]
    event.end_time = opts[:End]
    # extract tags from category, title and venue name
    tags = event.title.gsub(/\b(#{STOP_WORDS})\b/mi, '')
    tags = tags << " " << venue.title.gsub(/\b(#{STOP_WORDS})\b/mi, '')
    tags = tags.gsub(/[^a-zA-Z ]/i, '')
    tags = tags << " " << opts[:Category].to_s unless (opts[:Category].empty?)
    tags = tags.gsub(/ +/i, ' ')
    tags = tags.split(/ /)
    event.tag_list = tags.join(',')
    event.source = self
    event.description = event.description << "Category: " << opts[:Category] if (!opts[:Category].empty?)

    self.venues << venue
    self.events << event
    self.save
    #venue.save
    #event.save
    return event, venue
  end

  private

  # Ensure that the URL for this source is valid.
  def assert_url
    begin
      URI.parse(url)
      return true
    rescue URI::InvalidURIError => e
      errors.add("url", "has invalid format")
      return false
    end
  end

end
