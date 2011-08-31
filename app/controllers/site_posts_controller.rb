class SitePostsController < ApplicationController
  before_filter :is_admin, :except => [:index, :show]

  def index
    @site_posts = SitePost.order('created_at desc').paginate :page => params[:page], :per_page => 5 

  end

  def show
    @site_post = SitePost.find(params[:id])
    @next_post = SitePost.next_post(@site_post)
    @previous_post = SitePost.previous_post(@site_post)
  end

  # GET /site_posts/new
  # GET /site_posts/new.xml
  def new
    @site_post = SitePost.new
  end

  # GET /site_posts/1/edit
  def edit
    @site_post = SitePost.find(params[:id])
  end

  # POST /site_posts
  # POST /site_posts.xml
  def create
    @site_post = SitePost.new(params[:site_post])

    respond_to do |format|
      if @site_post.save 
        format.html { redirect_to(@site_post, :notice => 'Site post was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /site_posts/1
  # PUT /site_posts/1.xml
  def update
    @site_post = SitePost.find(params[:id])

    respond_to do |format|
      if @site_post.update_attributes(params[:site_post])
        format.html { redirect_to(@site_post, :notice => 'Site post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_posts/1
  # DELETE /site_posts/1.xml
  def destroy
    @site_post = SitePost.find(params[:id])
    @site_post.destroy

    respond_to do |format|
      format.html { redirect_to(site_posts_url) }
      format.xml  { head :ok }
    end
  end

   private 

  def is_admin
    raise ActionController::RoutingError.new("not such route") unless current_user.try(:admin?)
  end
end
