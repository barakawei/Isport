class ThemesController < ApplicationController
  before_filter :registrations_closed?
  before_filter :is_admin, :except => [:show ]

  def new
    @theme = Theme.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @theme }
    end
  end

  def edit
    @theme = Theme.find(params[:id])
  end

  def create
    @theme = Theme.new(params[:theme])

    respond_to do |format|
      if @theme.save
        format.html { redirect_to(@theme, :notice => 'Theme was successfully created.') }
        format.xml  { render :xml => @theme, :status => :created, :location => @theme }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @theme = Theme.find(params[:id])

    respond_to do |format|
      if @theme.update_attributes(params[:theme])
        format.html { redirect_to(@theme, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @theme = Theme.find(params[:id])

    if @theme.events.size == 0 && @theme.groups.size == 0
      @theme.destroy
      redirect_to(themes_url)
    else
      redirect_to(edit_theme_path(@theme), :notice => 'Can not delete theme with events, Delete events first!')
    end
  end

end
