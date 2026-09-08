require 'rails_helper'

describe 'Invitations', type: :request do
  let(:user) { create_user }
  let(:auth_token) { login_with_api(user) }
  let(:invitations_url) { '/api/v1/invitations' }

  context 'When invitation sent' do
    def make_request(email)
      post invitations_url, params: {
        invitation: {
          invitation_email: email
        }
      }, headers: {
        Authorization: auth_token
      }
    end

    it 'returns 201' do
      make_request('testinvitation@email.com')
      expect(response).to have_http_status(:created)
    end

    it 'make a request and wait for job to handle' do
      expect do
        make_request('test@email.com')
      end.to have_enqueued_job(InvitationMailerJob)
    end

    it 'fail if email is empty' do
      expect do
        make_request('')
      end.not_to have_enqueued_job(InvitationMailerJob)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
