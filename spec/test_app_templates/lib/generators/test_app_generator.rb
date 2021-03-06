require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../spec/test_app_templates", __FILE__)

  def add_gems
    gem 'blacklight-spotlight'
    Bundler.with_clean_env do
      run 'bundle install --quiet'
    end
  end

  def run_blacklight_generator
    say_status('warning', 'GENERATING BL', :yellow)
    generate 'blacklight:install', '--devise'
  end

  def run_spotlight_migrations
    rake 'spotlight:install:migrations'
    rake 'db:migrate'
  end

  def add_spotlight_routes_and_assets
    # spotlight will provide its own catalog controller.. remove blacklight's to
    # avoid getting prompted about file conflicts
    remove_file 'app/controllers/catalog_controller.rb'

    generate 'spotlight:install', '-f --mailer_default_url_host=localhost:3000'
    rake 'db:migrate'
  end

  def add_catalog_controller
    copy_file 'catalog_controller.rb', 'app/controllers/catalog_controller.rb', force: true
  end

  def configure_gdor
    copy_file 'gdor.yml', 'config/gdor.yml', force: true
  end

  def configure_papertrail
    copy_file 'paper_trail.rb', 'config/initializers/paper_trail.rb'
  end

  def run_spotlight_dor_resources_generator
    generate 'spotlight:dor:resources:install'
  end

end
