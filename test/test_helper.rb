require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'action_controller'


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'foreign_domain_routing'

class Test::Unit::TestCase
end
