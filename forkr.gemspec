Gem::Specification.new do |s|
  s.name        = 'forkr'
  s.version     = '1.0.1'
  s.date        = '2015-03-22'
  s.summary     = "A pre-forking worker host - shamelessly inspired by unicorn."
  s.description = "Forkr is a preforking worker host, shamelessly inspired by unicorn. It exists to easily fork and scale ruby programs which aren't rack-based."
  s.authors     = ["Trey Evans"]
  s.email       = 'lewis.r.evans@gmail.com'
  s.files       = ["lib/forkr.rb", "lib/multi_forkr.rb", "forkr.gemspec", "README.md"]
  s.homepage    = 'https://github.com/TreyE/forkr'
  s.license     = 'MIT'
end
