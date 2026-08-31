module ApiHelpers
  def json
    JSON.parse(response.body)
  end

  def login_with_api(account)
    post '/api/v1/auth/login', params: {
      account: {
        email: account.email,
        password: account.password
      }
    }

    response.headers['Authorization']
  end

  def set_devise_mapping
    request.env['devise.mapping'] = Devise.mappings[:account]
  end
end
