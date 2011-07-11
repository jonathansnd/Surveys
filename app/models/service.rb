class Service < ActiveRecord::Base
  belongs_to :user

  attr_accessible :provider, :uid, :uname, :uemail, :token, :token_secret, :token_refresh, :sf_consumer_key, :sf_consumer_secret,:instance_url, :org_id, :user_type, :active, :last_status_update, :last_status_created_date, :profile

end
