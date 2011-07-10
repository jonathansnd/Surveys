# Set the default hostname for omniauth to send callbacks to.
# seems to be a bug in omniauth that it drops the httpS
# this still exists in 0.2.0

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :salesforce, SALESFORCE_CONSUMER_KEY, SALESFORCE_CONSUMER_SECRET
end

OmniAuth.config.full_host = OMNIAUTH_FULL_HOST