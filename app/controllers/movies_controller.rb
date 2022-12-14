class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if params[:ratings].nil? == true
      @ratings_to_show = @all_ratings
    else
      session[:ratings] = params[:ratings]
      @ratings_to_show = params[:ratings].keys
    end
    @movies = Movie.with_ratings(@ratings_to_show)
    
    if params[:column].nil? == false
      session[:column] = params[:column]
      if params[:column] == 'title'
        @movies = Movie.sort_titles(@movies)
        @color_title = 'hilite bg-warning'
        @color_date = ''
      elsif params[:column] == 'date'
        @movies = Movie.sort_dates(@movies)
        @color_date = 'hilite bg-warning'
        @color_title = ''
      end 
    end

    if !params[:column] && !params[:ratings]
      if session[:ratings] && session[:column]
        @ratings_to_show = session[:ratings].keys
        redirect_to movies_path(:column => session[:column], :ratings => session[:ratings]) and return
      elsif session[:ratings]
        @ratings_to_show = session[:ratings].keys
        redirect_to movies_path(:ratings => session[:ratings]) and return
      elsif session[:column]
        redirect_to movies_path(:column => session[:column]) and return
      end
    end
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :column)
  end
end
