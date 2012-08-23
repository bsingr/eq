module EQ::Queueing
  module Backends
  end
end

require File.join(File.dirname(__FILE__), 'backends', 'sequel')
require File.join(File.dirname(__FILE__), 'backends', 'sorted_set')

