begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rsolr-em"
    gemspec.summary = "EventMachine Connection for RSolr"
    gemspec.description = "EventMachine/async based connection driver for RSolr -- compatible with Ruby 1.8"
    gemspec.email = "goodieboy@gmail.com"
    gemspec.homepage = "http://github.com/mwmitchell/rsolr-em"
    gemspec.authors = ["Colin Steele", "Matt Mitchell"]
    
    gemspec.files = FileList['lib/**/*.rb', 'LICENSE', 'README.rdoc', 'VERSION']
    
    gemspec.test_files = ['spec/**/*.rb', 'Rakefile']
    
    gemspec.add_dependency('eventmachine', '>=0.12.10')
    
    now = Time.now
    gemspec.date = "#{now.year}-#{now.month}-#{now.day}"
    
    gemspec.has_rdoc = true
  end
  
  # Jeweler::GemcutterTasks.new
  
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end