require 'sinatra/base'
require 'logger'
require 'json'
require 'faraday'
require 'openssl'
require 'base64'

module WebhookSignatureVerifier
  class App < Sinatra::Base
    DEFAULT_API_HOST = 'https://api.travis-ci.org'
    API_HOST = ENV.fetch('API_HOST', DEFAULT_API_HOST)

    configure :production, :development do
      enable :logging
    end

    configure :test do
      set :logging, ::Logger::ERROR
    end

    configure :development do
      set :logging, ::Logger::DEBUG
    end

    configure :production do
      set :logging, ::Logger::INFO
    end

    get '/' do
      status 200
      "Hello world!"
    end

    post '/verify' do
      begin
        payload      = request_body.fetch('payload', '')
        signature    = request.env["HTTP_SIGNATURE"]

        pkey = OpenSSL::PKey::RSA.new(public_key)

        if pkey.verify(
            OpenSSL::Digest::SHA1.new,
            Base64.decode64(signature),
            payload.to_json
          )
          status 200
          "verification succeeded"
        else
          status 400
          "verification failed"
        end

      rescue => e
        logger.info "exception=#{e.class} message=\"#{e.message}\""
        logger.debug e.backtrace.join("\n")

        status 500
        "exception encountered while verifying signature"
      end
    end

    def request_body
      JSON.parse(request.body.read)
    end

    def public_key
      conn = Faraday.new(:url => API_HOST) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
      response = conn.get '/config'
      JSON.parse(response.body)["config"]["notifications"]["webhook"]["public_key"]
    rescue
      ''
    end
  end
end
