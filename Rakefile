require 'active_record'
require 'yaml'

task :configure_connection do
	config = YAML::load_file('config.yaml')
    ActiveRecord::Base.establish_connection(:adapter => config['adapter'], :database => config['database'])
  end

desc 'Migrate the database'
  task :migrate => :configure_connection do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate 'db/migrate'
  end