# frozen_string_literal: true

module Gemview
  module Number
    # Ex. 1234567890 -> "1,234,567,890"
    # @param integer [Integer]
    # @return [String]
    def self.humanized_integer(integer)
      integer
        .to_s
        .chars
        .reverse
        .each_slice(3)
        .map(&:join)
        .join(",")
        .reverse
    end
  end
end
