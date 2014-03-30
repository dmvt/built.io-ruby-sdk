Gem::Specification.new do |s|
  s.name        = 'built.io'
  s.version     = '0.7'
  s.summary     = "The built.io Ruby SDK"
  s.description = <<-DOC
    built.io is a Backend-as-a-Service (BaaS).

    This is a Ruby SDK that provides a convenient API.
  DOC
  s.authors     = ["Suvish Thoovamalayil"]
  s.email       = 'vishy1618@gmail.com'
  s.homepage    = 'https://github.com/raweng/built.io-ruby-sdk'
  s.files       = Dir["lib/**/*"] + %w(MIT-LICENSE README.md)
  s.license     = 'MIT'

  s.add_runtime_dependency 'i18n', '0.6.1'
  s.add_runtime_dependency 'rest-client', '1.6.7'
  s.add_runtime_dependency 'dirty_hashy', '0.2.1'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
end