Gem::Specification.new do |s|
  s.name        = 'forkr'
  s.version     = '0.1.5'
  s.date        = '2014-12-03'
  s.summary     = "A pre-forking worker host - shamelessly inspired by unicorn."
  s.description = <<-DESCRIPTION
Forkr is a preforking worker host, shamelessly inspired by unicorn.

It exists to easily fork and scale ruby programs which aren't rack-based.
DESCRIPTION
  s.authors     = ["Trey Evans"]
  s.email       = 'lewis.r.evans@gmail.com'
  s.files       = ["lib/forkr.rb", "forkr.gemspec", "README.md"]
  s.homepage    = 'https://github.com/TreyE/forkr'
  s.license     = 'MIT'
end
