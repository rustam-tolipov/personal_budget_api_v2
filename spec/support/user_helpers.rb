require 'faker'

module UserHelpers
  def user_info
    password = Faker::Internet.password

    @user_info ||= {
      username: Faker::Internet.username,
      bio: Faker::Lorem.paragraph,
      email: Faker::Internet.email,
      password: password,
      password_confirmation: password
    }
  end

  def build_user
    FactoryBot.build(:account, username: user_info[:username], email: user_info[:email],
                               password: user_info[:password], password_confirmation: user_info[:password_confirmation])
  end

  def already_existing_user(u)
    FactoryBot.create(:account, username: u.username, email: u.email, password: u.password,
                                password_confirmation: u.password_confirmation)
  end

  def create_user
    FactoryBot.create(:account, username: user_info[:username], email: user_info[:email],
                                password: user_info[:password], password_confirmation: user_info[:password_confirmation])
  end

  def create_member
    FactoryBot.create(:member, username: Faker::Internet.username, bio: Faker::Lorem.paragraph, user_id: create_user.id)
  end
end
