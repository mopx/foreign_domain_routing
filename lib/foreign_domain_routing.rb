require 'foreign_domain_routing/routing_extensions'

module ForeignDomainRouting
  DEFAULT_NATIVE_DOMAINS = {:development => ['localhost:3000'], :test => ['test.host'], :production => ['example.com'] }
  DEFAULT_FOREIGN_SUBDOMAINS = {:development => false, :test => false, :production => false}
  mattr_accessor :init_native_domains, :init_foreign_subdomains
  @@init_native_domains = DEFAULT_NATIVE_DOMAINS.dup
  @@init_foreign_subdomains = DEFAULT_FOREIGN_SUBDOMAINS.dup
    
  def self.native_domains
    init_native_domains[RAILS_ENV.to_sym]
  end
  
  def self.native_domains=(value)
    init_native_domains[RAILS_ENV.to_sym] = value
  end

  def self.foreign_subdomains
    init_foreign_subdomains[RAILS_ENV.to_sym]
  end

  def self.foreign_subdomains=(value)
    init_foreign_subdomains[RAILS_ENV.to_sym] = value
  end

  def self.foreign_domain?(host)
    native_domains.each do |domain|
      if foreign_subdomains
        return false if host == domain # subdomains are foreign too.
      else
        return false if host =~ /#{domain}\Z/i
      end
    end
    true
  end
  
  module Controller
    def self.included(controller)
      controller.helper_method(:foreign_domain?)
    end
    
    protected
    
    def foreign_domain?
      ForeignDomainRouting.foreign_domain?(request.host)
    end
  end
end