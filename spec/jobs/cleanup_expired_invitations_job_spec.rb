require 'rails_helper'

RSpec.describe CleanupExpiredInvitationsJob, type: :job do
  include ActiveJob::TestHelper

  let(:account) { Account.create!(username: 'Tester', email: 'tester@email.com', password: 'bang!bang!') }
  let(:family_group) { FamilyGroup.create!(name: 'Our Family') }
  let!(:invitation) do
    Invitation.create!(invitation_email: 'test@email.com', expiration_date: 1.day.ago, family_group: family_group,
                       inviter: account, invitation_accepted: false)
  end

  it 'deletes expired invitations that were not accepted' do
    CleanupExpiredInvitationsJob.perform_now
    expect { invitation.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'keeps expired invitations that were accepted' do
    invitation.update!(invitation_accepted: true)
    CleanupExpiredInvitationsJob.perform_now
    expect(Invitation.exists?(invitation.id)).to be(true)
  end

  it 'keeps invitations that have not expired yet'
end
