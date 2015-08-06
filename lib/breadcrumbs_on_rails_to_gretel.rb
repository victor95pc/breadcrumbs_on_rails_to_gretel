module BreadcrumbsOnRailsToGretel
	require "breadcrumbs_on_rails_to_gretel/railtie.rb"
	require "breadcrumbs_on_rails_to_gretel/search_old_breadcrumbs.rb"
	if Rails::VERSION::MAJOR >= 4
		BEFORE = :before_action
	else
		BEFORE = :before_filter
	end
end