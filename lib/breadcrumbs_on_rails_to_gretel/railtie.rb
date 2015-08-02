require 'breadcrumbs_on_rails_to_gretel'
require 'rails'

module BreadcrumbsOnRailsToGretel
  class Railtie < Rails::Railtie
    rake_tasks do
    	load "tasks/breadcrumbs_on_rails_to_gretel.rake"
    end
  end
end