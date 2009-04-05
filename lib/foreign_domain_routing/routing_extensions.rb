module ForeignDomainRouting
  module RouteExtensions

    TESTABLE_REQUEST_METHODS = [:subdomain, :domain, :method, :port, :remote_ip, 
                                :content_type, :accepts, :request_uri, :protocol]
    
    def self.included(base)
      base.alias_method_chain :recognition_conditions, :foreign_domain
    end

    def recognition_conditions_with_foreign_domain      
      result = recognition_conditions_without_foreign_domain
      result << "ForeignDomainRouting.foreign_domain?(env[:host])" if conditions[:foreign_domain] == true
      result << "!ForeignDomainRouting.foreign_domain?(env[:host])" if conditions[:foreign_domain] == false
      
      conditions.each do |method, value|
        if TESTABLE_REQUEST_METHODS.include? method
          result << if value.is_a? Regexp
            "conditions[#{method.inspect}] =~ env[#{method.inspect}]"
          else
            "conditions[#{method.inspect}] === env[#{method.inspect}]"
          end
        else
        end
      end
      
      
      result
    end
  end

  module RouteSetExtensions
    def self.included(base)
      base.alias_method_chain :extract_request_environment, :foreign_domain
    end

    def extract_request_environment_with_foreign_domain(request)
      extract_request_environment_without_foreign_domain(request).merge({ 
        :host => request.host,
        :method => request.method,
        :subdomain => request.subdomains.first.to_s, 
        :domain => request.domain, 
        :port => request.port, 
        :remote_ip => request.remote_ip, 
        :content_type => request.content_type, 
        :accepts => request.accepts.map(&:to_s).join(','), 
        :request_uri => request.request_uri, 
        :protocol => request.protocol
        })
    end
  end
end

ActionController::Routing::RouteSet.send :include, ForeignDomainRouting::RouteSetExtensions
ActionController::Routing::Route.send :include, ForeignDomainRouting::RouteExtensions