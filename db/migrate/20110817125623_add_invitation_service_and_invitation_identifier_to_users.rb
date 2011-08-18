class AddInvitationServiceAndInvitationIdentifierToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invitation_service, :string
    add_column :users, :invitation_identifier, :string
  end

  def self.down
    remove_column :users, :invitation_identifier
    remove_column :users, :invitation_service
  end
end
