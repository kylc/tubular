$LOAD_PATH.unshift(File.expand_path(File.join(__dir__, "..", "lib")))

require 'minitest/autorun'
require 'webmock/minitest'

require 'tubular'

# TODO: Submit this upstream
MiniTest::Spec.class_eval do
  include WebMock::API
end

