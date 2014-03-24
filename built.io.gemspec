Gem::Specification.new do |s|
  s.name        = 'built.io'
  s.version     = '0.3'
  s.summary     = "The built.io Ruby SDK"
  s.description = <<-DOC
    built.io is a Backend-as-a-Service (BaaS).

    This is a Ruby SDK that provides a convenient API.
  DOC
  s.authors     = ["Suvish Thoovamalayil"]
  s.email       = 'vishy1618@gmail.com'
  s.homepage    = 'https://github.com/raweng/built.io-ruby-sdk'
  s.files       = Dir["lib/**/*", "doc/**/*"] + %w(MIT-LICENSE README.md)
  s.license     = 'MIT'

  s.add_runtime_dependency 'i18n'
  s.add_runtime_dependency 'httmultiparty'
end