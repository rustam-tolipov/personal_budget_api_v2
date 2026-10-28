require 'rails_helper'

RSpec.describe InvitationMailerJob, type: :job do
  let(:account) { Account.create!(username: 'Tester', email: 'tester@email.com', password: 'bang!bang!') }
  let(:family_group) { FamilyGroup.create!(name: 'Our Family') }
  let(:invitation) do
    Invitation.create!(invitation_email: 'test@email.com', expiration_date: '2027/01/01', family_group: family_group,
                       inviter: account)
  end

  it 're-enqueues itself when SMTP times out' do
    allow(InvitationMailer).to receive(:invite).and_raise(Net::OpenTimeout)
    expect do
      InvitationMailerJob.perform_now(invitation.id)
    end.to have_enqueued_job(InvitationMailerJob).with(invitation.id)
  end
end
