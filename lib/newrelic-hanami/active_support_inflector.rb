# frozen_string_literal: true

module NewRelic
  module Hanami
    # Copy of Rails' `underscore` method from ActiveSupport::Inflector
    # https://github.com/rails/rails/blob/v7.0.4/activesupport/lib/active_support/inflector/inflections.rb
    module ActiveSupportInflector
      ACRONYMS                  = {}.freeze
      ACRONYM_REGEX             = ACRONYMS.empty? ? /(?=a)b/ : /#{ACRONYMS.values.join("|")}/
      ACRONYMS_UNDERSCORE_REGEX = /(?:(?<=([A-Za-z\d]))|\b)(#{ACRONYM_REGEX})(?=\b|[^a-z])/.freeze

      class << self
        def underscore(camel_cased_word)
          return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)

          word = camel_cased_word.to_s.gsub('::', '/')
          word.gsub!(ACRONYMS_UNDERSCORE_REGEX) { "#{$1 && '_'}#{$2.downcase}" } # rubocop:disable Style/PerlBackrefs
          word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          word.tr!('-', '_')
          word.downcase!

          word
        end
      end
    end
  end
end
