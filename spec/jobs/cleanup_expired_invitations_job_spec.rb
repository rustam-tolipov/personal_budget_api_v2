require 'rails_helper'

RSpec.describe CleanupExpiredInvitationsJob, type: :job do
  include ActiveJob::TestHelper

  it 'deletes expired invitations that were not accepted'

  it 'keeps expired invitations that were accepted'

  it 'keeps invitations that have not expired yet'
end
