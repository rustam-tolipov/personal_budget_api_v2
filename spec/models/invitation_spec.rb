require 'rails_helper'

RSpec.describe Invitation, type: :model do
  before do
    @account = Account.create!(username: 'Tester', email: 'tester@email.com', password: 'bang!bang!')
    @family_group = FamilyGroup.create!(name: 'Our Family')
    @invitation = Invitation.create!(invitation_email: 'test@email.com', expiration_date: '2027/01/01',
                                     family_group: @family_group, inviter: @account)
  end

  it 'generates a token on create' do
    expect(@invitation.token).to be_present
  end

  it 'is invalid without an email' do
    invitation = Invitation.new(invitation_email: '', expiration_date: '2027/01/01',
                                family_group: @family_group, inviter: @account)
    expect(invitation).not_to be_valid
  end

  it 'rejects a duplicate email in the same group' do
    second_invitation = Invitation.new(invitation_email: 'test@email.com', expiration_date: '2027/01/01',
                                       family_group: @family_group, inviter: @account)
    expect(second_invitation).not_to be_valid
  end
end
