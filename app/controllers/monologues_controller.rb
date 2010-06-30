require 'vendor/plugins/active_record_extensions'
class MonologuesController < ApplicationController
  
  def index
    @comedies = Play.find_all_by_classification('Comedy')
    @histories = Play.find_all_by_classification('History')
    @tragedies = Play.find_all_by_classification('Tragedy')
    render :index
  end
  
  def show
    @monologue = Monologue.find(params[:id])
    render :show
  end

  def new
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @monologue = Monologue.new
    @plays = Play.all
    @genders = Gender.all
    render :action => 'new', :layout => 'admin'
  end

  def edit
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @monologue = Monologue.find(params[:id])
    @plays = Play.all
    render :action => 'edit', :layout => 'admin'
  end

  def create
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @monologue = Monologue.new(params[:monologue])
    if @monologue.save
      flash[:notice] = "Successfully created monologue."
      redirect_to @monologue
    else
      @plays = Play.all
      @genders = Gender.all
      render :action => 'new'
    end
  end

  def update
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @monologue = Monologue.find(params[:id])
    if @monologue.update_attributes(params[:monologue])
      expire_fragment /\/monologue\/#{@monologue.id}\/.+/
      flash[:notice] = "Successfully updated monologue."
      redirect_to @monologue
    else
      @plays = Play.all
      @genders = Gender.all
      render :action => 'edit'
    end
  end

  def destroy
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @monologue = Monologue.find(params[:id])
    @monologue.destroy
    flash[:notice] = "Successfully destroyed monologue."
    redirect_to monologues_url
  end



  def preview
    @monologue = Monologue.find(params[:id]) if params[:id]
    render :partial => 'shared/preview', :layout => false
  end
  
  def search
    @ajax_search = params[:search]
    @play_id = params[:p]
    @gender_id = params[:g]
    @both_gender_id = GENDER[ 'Both' ]

    if @ajax_search.blank?

      # no search terms
      if @play_id and @gender_id
        @monologues = Monologue.find(
          :all,
          :conditions =>
            ['(gender_id = ? OR gender_id = ?) AND play_id = ?', @gender_id, @both_gender_id, @play_id]
        )

      elsif @play_id
        @monologues = Monologue.find_all_by_play_id(@play_id)
        
      elsif @gender_id
        # this branch (gender_id, but no search terms) might be unused
        @monologues = Monologue.find(
          :all,
          :limit => 20,
          :conditions =>
            ['gender_id = ? OR gender_id = ?', @gender_id, @both_gender_id]
        )
      else
        # this branch (no search terms) might be unused
        @monologues = Monologue.all(:limit => 20)
      end

    else
      @terms = @ajax_search.split(" ")
      @monologues = []
      @terms.each do |term|
        
        # set the default value for term_like_sql
        case ActiveRecord::Base.connection.adapter_name
        when 'PostgreSQL'
          term_like_sql = '(plays.title ilike ? OR character ilike ? OR body ilike ? OR first_line ilike ?)'
          term_like_sql_no_play = '(character ilike ? OR body ilike ? OR first_line ilike ?)'
        else
          term_like_sql = '(plays.title like ? OR character like ? OR body like ? OR first_line like ?)'
          term_like_sql_no_play = '(character like ? OR body like ? OR first_line like ?)'
        end

        if @gender_id and @play_id
          # gender and play specified
          results = Monologue.find(
            :all,
            :conditions =>
              ['(gender_id = ? OR gender_id = ?) AND play_id = ? AND ' + term_like_sql_no_play,
                @gender_id, @both_gender_id, @play_id, "%#{term}%", "%#{term}%", "%#{term}%"],
            :joins => :play
          )
        elsif @play_id
          # play specified
          results = Monologue.find(
            :all,
            :conditions =>
              ['play_id = ? AND ' + term_like_sql_no_play,
                @play_id, "%#{term}%", "%#{term}%", "%#{term}%"],
            :joins => :play
          )
        elsif @gender_id
          # gender specified
          results = Monologue.find(
            :all,
            :conditions =>
              ['(gender_id = ? OR gender_id = ?) AND ' + term_like_sql,
                @gender_id, @both_gender_id, "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"],
            :joins => :play
          )
        else
          # all monologues
          results = Monologue.find(
            :all,
            :conditions =>
              [term_like_sql,
              "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"],
            :joins => :play
          )
        end
        if results
          if @monologues.empty?
            @monologues = results
          else
            # append results for each seach term
            @monologues &= results
          end
        end

      end

      @monologues.compact!
      @monologues.uniq!
      if @play_id
        @monologues = @monologues.sort_by{|mono| mono.location }
      elsif
        @monologues = @monologues.sort_by{|mono| [mono.play.title, mono.location] }
      end
    end

    @comedies = Play.find_all_by_classification('Comedy')
    @histories = Play.find_all_by_classification('History')
    @tragedies = Play.find_all_by_classification('Tragedy')
    
    render :partial => 'shared/search', :layout => false
  end

  def men
    @monologues = Monologue.find_all_by_name('Men')
    @comedies = Play.find_all_by_classification('Comedy')
    @histories = Play.find_all_by_classification('History')
    @tragedies = Play.find_all_by_classification('Tragedy')
    render :index
  end

  def women
    @monologues = Monologue.find_all_by_name('Women')
    @comedies = Play.find_all_by_classification('Comedy')
    @histories = Play.find_all_by_classification('History')
    @tragedies = Play.find_all_by_classification('Tragedy')
    render :index
  end

end
