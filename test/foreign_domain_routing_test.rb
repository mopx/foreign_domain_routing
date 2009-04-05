require 'test_helper'

require File.dirname(__FILE__) + "/../init"
RAILS_ENV = :test

class TestController < Class.new(ActionController::Base)
  def thing
  end
end

class OtherTestController < Class.new(ActionController::Base)
  def thing
  end
end

class MockRequest < Struct.new(:path, :subdomains, :method, :remote_ip, :protocol, :path_parameters, :domain, :port, :content_type, :accepts, :request_uri, :host)
end

class ForeignDomainRoutingTest < ActionController::TestCase
  attr_reader :rs
  def setup
    @rs = ::ActionController::Routing::RouteSet.new
    ActionController::Routing.use_controllers! %w(test) if ActionController::Routing.respond_to? :use_controllers!
    @rs.draw {|m| m.connect ':controller/:action/:id' }
    @request = MockRequest.new(
      '',
      ['www'],
      :post,
      '1.2.3.4',
      'http://',
      '',
      'thing.com',
      3432,
      'text/html',
      ['*/*'],
      '/',
      'www.example.com'
    )
  end
  
  test "should route normally" do
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end
    
    @request.path = '/test/thing'
    assert(@rs.recognize(@request))    
  end
  
  test "should route conditionally on subdomain" do
    @rs.draw { |m| m.connect 'thing', :controller => 'test', :conditions => { :subdomain => 'www' }  }
    @request.path = '/thing'
    assert(@rs.recognize(@request))
    @request.subdomains = ['sdkg']
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end    
  end
  
  test "should route conditionally on protocol" do
    @rs.draw { |m| m.connect 'thing', :controller => 'test', :conditions => { :protocol => /^https:/ }  }
    @request.path = '/thing'
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end
    
    @request.protocol = "https://"
    assert(@rs.recognize(@request))
  end

  test "should route conditionally on alternate conditionals" do
    @rs.draw { |m| 
      m.connect 'thing', :controller => 'test', :conditions => { :remote_ip => '1.2.3.4' }  
      m.connect 'thing', :controller => 'other_test', :conditions => { :remote_ip => '1.2.3.5' }
    }
    
    @request.path = '/thing'
    assert(@rs.recognize(@request))
    
    @request.remote_ip = '1.2.3.5'
    assert(@rs.recognize(@request))
  end
  
  test "should route conditionally on foreign domain" do
    ForeignDomainRouting.init_native_domains = {
      :development => ['localhost'], 
      :test => ['www.example.com'],
      :production => ['example.com', 'example.org', 'example.net']
    }
    
    @rs.draw { |m| m.connect 'thing', :controller => 'test', :conditions => { :foreign_domain => false }  }
    @request.path = '/thing'
    assert(@rs.recognize(@request))
    @request.host = ['foreign.domain.com']
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end
    @rs.draw { |m| m.connect 'thing', :controller => 'test', :conditions => { :foreign_domain => true }  }
    @request.path = '/thing'
    assert(@rs.recognize(@request))
  end
  
  test "should route conditionally on foreign domain and protocol" do
    ForeignDomainRouting.init_native_domains = {
      :development => ['localhost'], 
      :test => ['www.example.com'],
      :production => ['example.com', 'example.org', 'example.net']
    }
    
    @rs.draw { |m| m.connect 'thing', :controller => 'test', :conditions => { :foreign_domain => false, :protocol => /^http:/ }  }
    @request.path = '/thing'
    # :foreign_domain => false, :protocol => http:// (MATCH)
    assert(@rs.recognize(@request))

    # :foreign_domain => false, :protocol => https:// (NO MATCH)
    @request.protocol = "https://"
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end

    # :foreign_domain => true, :protocol => http:// (NO MATCH)
    @request.host = ['foreign.domain.com']
    @request.protocol = "http://"
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end

    # :foreign_domain => true, :protocol => https:// (NO MATCH)
    @request.protocol = "https://"
    assert_raise(ActionController::RoutingError) do
      @rs.recognize(@request)
    end
    
  end
end
