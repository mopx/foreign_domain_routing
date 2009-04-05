# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{foreign-domain-routing}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joe Scharf"]
  s.date = %q{2009-04-05}
  s.email = %q{joe@quantipay.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["VERSION.yml", "lib/foreign_domain_routing", "lib/foreign_domain_routing/routing_extensions.rb", "lib/foreign_domain_routing.rb", "test/foreign_domain_routing_test.rb", "test/test_helper.rb", "README"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/quantipay/foreign-domain-routing-gem}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{This version of foreign_domain_routing merges foreign_domain_routing with request_routing}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
