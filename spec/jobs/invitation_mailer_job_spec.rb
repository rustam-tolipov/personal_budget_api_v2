require 'rails_helper'

RSpec.describe InvitationMailerJob, type: :job do
  include ActiveJob::TestHelper

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

  it 'raise the error after the last attempt' do
    allow(InvitationMailer).to receive(:invite).and_raise(Net::OpenTimeout)
    perform_enqueued_jobs do
      expect do
        InvitationMailerJob.perform_later(invitation.id)
      end.to raise_error(Net::OpenTimeout)
    end
    expect(InvitationMailer).to have_received(:invite).exactly(5).times
    expect(invitation.reload.sent_at).to be_nil
  end
end
