#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < Devise::InvitationsController
  before_filter :check_token, :only => [:edit]

  def new
    @sent_invitations = current_user.invitations_from_me.includes(:recipient)
    respond_to do |format|
      format.html do
        render :layout => false 
      end
    end
  end

  def create
    unless AppConfig[:open_invitations]
      flash[:error] = I18n.t 'invitations.create.no_more'
      redirect_to :back
      return
    end
    message = params[:user].delete(:invite_messages)
    emails = params[:user][:email].to_s.gsub(/\s/, '').split(/, */)

    good_emails, bad_emails = emails.partition{|e| e.try(:match, Devise.email_regexp)}

    if good_emails.include?(current_user.email)
      if good_emails.length == 1
        flash[:error] = I18n.t 'invitations.create.own_address'
        redirect_to :back
        return
      else
        bad_emails.push(current_user.email)
        good_emails.delete(current_user.email)
      end
    end
    good_emails.each{|e| current_user.invite_user('email',e, message)}
    redirect_to :back
  end

  def update
    begin
      invitation_token = params[:user][:invitation_token]
      if invitation_token.nil? || invitation_token.blank?
        raise I18n.t('invitations.check_token.not_found')
      end
      user = User.find_by_invitation_token(params[:user][:invitation_token])
      user.accept_invitation!(params[:user])
    rescue Exception => e
      raise e unless e.respond_to?(:record)
      user = nil
      record = e.record
      record.errors.delete(:person)
      flash[:error] = record.errors.full_messages.join(", ")  
    end

    if user
      flash[:notice] = I18n.t ('registrations.create.success')
      sign_in_and_redirect(:user, user)
    else
      redirect_to accept_user_invitation_path(
        :invitation_token => params[:user][:invitation_token])
    end
  end

  def resend
    invitation = current_user.invitations_from_me.where(:id => params[:id]).first
    if invitation
      invitation.resend
      flash[:notice] = I18n.t('invitations.create.sent') + invitation.recipient.email
    end
    redirect_to :back
  end

  def email
    @invs = []
    @resource = User.find_by_invitation_token(params[:invitation_token])
    render 'devise/mailer/invitation_instructions', :layout => false
  end
  protected

  def check_token
    if User.find_by_invitation_token(params[:invitation_token]).nil?
      flash[:error] = I18n.t 'invitations.check_token.not_found'
      redirect_to root_url
    end
  end
end
