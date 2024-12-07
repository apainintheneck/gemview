# frozen_string_literal: true

module Gemview
  module Client
    # Create a client manually so that we don't accidentally pick up credentials.
    def self.v1
      @client_v1 ||= Gems::V1::Client.new(
        username: nil,
        password: nil,
        key: nil
      )
    end

    # Create a client manually so that we don't accidentally pick up credentials.
    def self.v2
      @client_v2 ||= Gems::V2::Client.new(
        username: nil,
        password: nil,
        key: nil
      )
    end
  end
end
