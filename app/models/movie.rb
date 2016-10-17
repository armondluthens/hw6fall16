class Movie < ActiveRecord::Base
  
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
  class Movie::InvalidKeyError < StandardError ; end
  
  
  
  def self.find_in_tmdb(string)
    begin
      movie_hash_array = []
      
      Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
      movie_object_array = Tmdb::Movie.find(string)
      
      #iterate through movie object array to create hashes
      movie_object_array.each do |m|
        m_hash = Hash.new
        
        m_id = m.id
        m_title = m.title
        
        rating = Tmdb::Movie.releases(m.id)
        
        if rating['countries'].empty? then rating = "Not Found"
        else
          rating = rating['countries'].select{|valid_search| valid_search['iso_3166_1'] == 'US'}
          
          if rating.count > 0
            rating = rating[0]['certification']
          end
        end
        if rating.empty? then rating = "Not Found"
        end
    
        m_rating = rating
        m_release_date = m.release_date
        
        m_hash = {:tmdb_id => m_id, :title => m_title, :rating => m_rating, :release_date => m_release_date}
        
        movie_hash_array.push(m_hash)
      end
      
      #return array of hashes
      return movie_hash_array
      
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.create_from_tmdb(tmdb_id)
    #get hash of the movie info of the movies being added
    movie_details = Tmdb::Movie.detail(tmdb_id)
    
    movie_details_hash = Hash.new
    
    movie_details_hash[:title] = movie_details['title']
    movie_details_hash[:release_date] = movie_details['release_date']
    movie_details_hash[:description] = movie_details['overview']
    
    ###########################################################################
    rating = Tmdb::Movie.releases(tmdb_id)
    if rating['countries'].empty? then rating = "Not Found"
    else
      rating = rating['countries'].select{|valid_search| valid_search['iso_3166_1'] == 'US'}
          
      if rating.count > 0
        rating = rating[0]['certification']
      end
    end
    if rating.empty? then rating = "Not Found"
    end
    
    m_rating = rating
    ###########################################################################
    movie_details_hash[:rating] = m_rating
    
    
    
    Movie.create!(movie_details_hash)
    
  end
  
  


end
