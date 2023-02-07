module Users::AllowList
    extend ActiveSupport::Concern
  
    included do
      has_many :allowlisted_jwts, dependent: :destroy
  
      def self.jwt_revoked?(payload, user)
        !user.allowlisted_jwts.exists?(payload.slice('jti'))
      end
  
      def self.revoke_jwt(payload, user)
        jwt = user.allowlisted_jwts.find_by(payload.slice('jti'))
        jwt.destroy! if jwt
      end
    end
  
    def on_jwt_dispatch(_token, payload)
      token = allowlisted_jwts.create!(
        jti: payload['jti'],
        exp: Time.at(payload['exp'].to_i)
      )
      token
    end
  end