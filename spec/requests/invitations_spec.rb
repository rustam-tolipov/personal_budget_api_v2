require 'rails_helper'

describe 'Invitations', type: :request do
  # create_user memoizes user_info with ||=, so a second call reuses the same
  # email/username and fails uniqueness. Extra accounts need unique values.
  def make_account(name)
    suffix = SecureRandom.hex(3)
    FactoryBot.create(:account, username: "#{name}_#{suffix}", email: "#{name}_#{suffix}@example.com",
                                password: 'password123', password_confirmation: 'password123')
  end

  let(:user) { make_account('admin') }
  let(:auth_token) { login_with_api(user) }
  let(:family_group) { FamilyGroup.create!(name: 'Family Group', owner_id: user.id) }
  let!(:family_group_membership) do
    FamilyGroupMembership.create!(family_group: family_group, account: user, role: :admin)
  end
  let(:invitations_in_group) { "/api/v1/family_groups/#{family_group.id}/invitations" }

  context 'When invitation sent' do
    def make_request(email, token: auth_token)
      headers = token ? { Authorization: token } : {}

      post invitations_in_group, params: {
        invitation: {
          invitation_email: email
        }
      }, headers: headers
    end

    it 'returns 201' do
      make_request('testinvitation@email.com')
      expect(response).to have_http_status(:created)
    end

    it 'make a request and wait for job to handle' do
      make_request('test@email.com')
      expect(InvitationMailerJob).to have_been_enqueued.with(Invitation.last.id)
    end

    it 'fail if email is empty' do
      expect do
        make_request('')
      end.not_to have_enqueued_job(InvitationMailerJob)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 401 if not logged in' do
      make_request('test@email.com', token: nil)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 404 if not a member of the group' do
      stranger = make_account('stranger')
      make_request('test@email.com', token: login_with_api(stranger))
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 403 if member but not an admin' do
      member = make_account('member')
      FamilyGroupMembership.create!(family_group: family_group, account: member, role: :member)
      make_request('test@email.com', token: login_with_api(member))
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 422 + no jobs for invalid email' do
      expect do
        make_request('not-an-email')
      end.not_to have_enqueued_job(InvitationMailerJob)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 422 if the same email invited twice' do
      make_request('twice@email.com')
      make_request('twice@email.com')
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Invitation.where(invitation_email: 'twice@email.com').count).to eq(1)
    end
  end
end
