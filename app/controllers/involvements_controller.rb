class InvolvementsController < ApplicationController
  before_filter :init
  prepend_before_filter :authenticate_user!

  def destroy
    unless params[:member_ids]
      @involvement = Involvement.find_by_event_id_and_person_id(@event.id, @person.id)
      @involvement.destroy if @involvement && @event.quitable?
    else
      member_ids = params[:member_ids].split(',');
      if @event && member_ids && @event.owner == @person
        Involvement.delete_all(:event_id => @event.id, :person_id => member_ids)
      end
    end
    redirect_to :back
  end

  def create
    Involvement.create(:event_id => @event.id, :person_id => @person.id) if @event.joinable?
    redirect_to :back
  end

  def invite
     if params[:selectedIds] && params[:selectedIds].length > 0
        person_ids = params[:selectedIds].split(',');
        person_ids.each do |person_id|
          Involvement.create(:event_id => @event.id, :person_id => person_id,
                            :is_pending => true)
        end
     end 
     render :nothing => true
  end

  private
  def init
    @event = Event.find(params[:id])
    @person = current_user.person 
  end
end
