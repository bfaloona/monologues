class AuthorsController < ApplicationController
  # GET /authors
  # GET /authors.xml
  def index
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @authors = Author.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @authors }
    end
  end

  # GET /authors/1
  # GET /authors/1.xml
  def show
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @author = Author.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @author }
    end
  end

  # GET /authors/new
  # GET /authors/new.xml
  def new
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @author = Author.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @author }
    end
  end

  # GET /authors/1/edit
  def edit
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @author = Author.find(params[:id])
  end

  # POST /authors
  # POST /authors.xml
  def create
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @author = Author.new(params[:author])

    respond_to do |format|
      if @author.save
        flash[:notice] = 'Author was successfully created.'
        format.html { redirect_to(@author) }
        format.xml  { render :xml => @author, :status => :created, :location => @author }
      else
        format.html { render :action => "new" }
        format.xml  { raise 'foo'; render :xml => @author.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /authors/1
  # PUT /authors/1.xml
  def update
    unless logged_in?
      redirect_to new_login_url
      return
    end
    @author = Author.find(params[:id])

    respond_to do |format|
      if @author.update_attributes(params[:author])
        flash[:notice] = 'Author was successfully updated.'
        format.html { redirect_to(@author) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @author.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1
  # DELETE /authors/1.xml
  def destroy
    unless logged_in?
      redirect_to new_login_url 
      return
    end
    @author = Author.find(params[:id])
    @author.destroy

    respond_to do |format|
      format.html { redirect_to(authors_url) }
      format.xml  { head :ok }
    end
  end
end
