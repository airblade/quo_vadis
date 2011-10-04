require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module QuoVadis
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)
    argument :model_name, :type => :string, :default => 'User'

    desc 'Copies an initializer, a locale file, and a migration to your application.'


    def copy_locale_file
      copy_file '../../../../config/locales/quo_vadis.en.yml', 'config/locales/quo_vadis.en.yml'
    end

    def copy_initializer_file
      template 'quo_vadis.rb.erb', 'config/initializers/quo_vadis.rb'
    end

    def create_migration_file
      migration_template 'migration.rb.erb', "db/migrate/add_authentication_to_#{model_name.tableize}.rb"
    end

  end
end
