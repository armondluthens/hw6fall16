class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:release_date => :asc}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}
    
    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
    
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def search_tmdb
    
    @movies_hash = Hash.new
    
    @search_query = params[:search_box]
    if @search_query == "" || @search_query == nil
      flash[:notice] = "Invalid Search Terms Entered"
      redirect_to movies_path
    else
      @valid_search = Hash.new
      @movies_returned = Movie.find_in_tmdb(@search_query)

      if @movies_returned.empty?
        flash[:notice] = "No Movies Found On TMDb Matching Your Search"
        redirect_to movies_path
      end
    end

  end #end of search_tmdb
  
  def add_tmdb_movies
    selected_movies_hash = params[:tmdb_movies]
    tmdb_ids_array = selected_movies_hash.keys
    
    if selected_movies_hash.empty?
      flash[:notice] = "No Movies Found On TMDb Matching Your Search"
    else
      tmdb_ids_array.each do |current_id|
        Movie.create_from_tmdb(current_id)
      end
    end
    
    redirect_to movies_path
  end

end
