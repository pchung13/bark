begin
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new("spec") do |t|
  t.pattern = "./spec/**/*_spec.rb"
  t.rspec_opts = %w(-fs --color)
end

task :default => :spec
rescue LoadError
  puts "RSpec is not part of this bundle, skip specs."
end
