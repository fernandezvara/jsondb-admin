Gem::Specification.new do |s|
  s.name        = 'jsondb_admin'
  s.version     = '0.0.1'
  s.date        = '2014-10-06'
  s.summary     = "Sinatra application that helps administering databases created with 'jsondb' gem."
  s.description = "Administers 'jsondb' gem databases."
  s.authors     = ["Antonio Fernandez"]
  s.email       = 'antoniofernandezvara@gmail.com'
  s.files       = [
    "lib/jsondb_admin.rb",
  ]
  s.executables = ['jsondbadmin']
  s.default_executable = 'jsondbadmin'
  s.homepage    = 'http://fernandezvara.github.io/jsondb/'
  s.license     = 'MIT'
  s.add_runtime_dependency 'json_pure', '= 1.8.1'
  s.add_runtime_dependency 'jsondb', '= 0.1.6'
end