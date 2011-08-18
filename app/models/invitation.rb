class Invitation < ActiveRecord::Base

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  # @param opts [Hash] Takes :identifier, :service, :idenfitier, :from, :message
  # @return [User]
  def self.invite(opts={})
    opts[:identifier].downcase! if opts[:identifier]
    # return if the current user is trying to invite himself via email
    return false if opts[:identifier] == opts[:from].email

    if existing_user = self.find_existing_user(opts[:service], opts[:identifier])
      # If the sender of the invitation is already connected to the person
      # he is inviting, raise an error.
      if opts[:from].contact_for(opts[:from].person)
        raise "You are already connceted to this person"

      # Check whether or not the existing User has already been invited;
      # and if so, start sharing with the Person.
      elsif not existing_user.invited?
        opts[:from].share_with(existing_user.person, opts[:into])
        return

      # If the sender has already invited the recipient, raise an error.
      elsif Invitation.where(:sender_id => opts[:from].id, :recipient_id => existing_user.id).first
        raise "You already invited this person"

      # When everything checks out, we merge the existing user into the
      # options hash to pass on to self.create_invitee.
      else
        opts.merge(:existing_user => existing_user)
      end
    end

    create_invitee(opts)
  end

  # @param service [String] String representation of the service invitation provider (i.e. facebook, email)
  # @param identifier [String] String representation of the reciepients identity on the provider (i.e. 'bob.smith', bob@aol.com)
  # @return [User]
  def self.find_existing_user(service, identifier)
    unless existing_user = User.where(:invitation_service => service,
                                      :invitation_identifier => identifier).first
      if service == 'email'
        existing_user ||= User.where(:email => identifier).first
      end
    end

    existing_user
  end

  # @params opts [Hash] Takes :from, :existing_user, :service, :identifier, :message
  # @return [User]
  def self.create_invitee(opts={})
    invitee = opts[:existing_user]
    invitee ||= User.new(:email =>opts[:identifier],:invitation_service => opts[:service], :invitation_identifier => opts[:identifier])

    # (dan) I'm not sure why, but we need to call .valid? on our User.
    invitee.valid?

    # Return a User immediately if an invalid email is passed in
    return invitee if opts[:service] == 'email' && !opts[:identifier].match(Devise.email_regexp)
    if invitee.new_record?
      invitee.send(:generate_invitation_token)
    end

    # Logic if there is an explicit sender
    if opts[:from]
      invitee.save(:validate => false)
      Invitation.create!(:sender => opts[:from],
                         :recipient => invitee,
                         :message => opts[:message])
      invitee.reload
    end
    invitee.skip_invitation = (opts[:service] != 'email')
    invitee.invite!

    invitee
  end

  def resend
    recipient.invite!
  end

  # @return Contact
  def share_with!
    if sender.share_with(recipient.person) && recipient.share_with( sender.person )
      self.destroy
    end
  end

  # @return [String]
  def recipient_identifier
    if recipient.invitation_service == 'email'
      recipient.invitation_identifier
    end
  end
end

