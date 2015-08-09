module BreadcrumbsOnRailsToGretel
	class SearchOldBreadcrumbs
		require 'ruby2ruby'
		require 'ruby_parser'
		attr_accessor :breadcrumbs, :breadcrumbs_root, :breadcrumbs_controller, :parser, :ruby2ruby, :controller_sexp, :klass

		def initialize
			self.parser           = ::RubyParser.new
			self.ruby2ruby        = ::Ruby2Ruby.new
			self.breadcrumbs      = {}
			self.breadcrumbs_root = []
		end

		def look_all_controllers
			Rails.root.join('app', 'controllers').each_child do |file| 
				prepare_controller(file)
				search_on_class_methods

				if klass == ApplicationController
					breadcrumbs_root << breadcrumbs_controller
				else
					search_on_actions
					breadcrumbs[klass] ||= []
					breadcrumbs[klass] << breadcrumbs_controller
				end
			end
		end

		private

		def prepare_controller(file)
			self.breadcrumbs_controller = {}
			self.controller_sexp        = parser.process(File.open(file).read)

			self.klass = Kernel.const_get controller_sexp[1]
		end

		def search_on_class_methods
			controller_sexp.find_nodes(:call).select { |sexp| %i(add_breadcrumb before_action before_filter).include? method_name(sexp) }.each do |sexp|
				
				options = get_callback_options(sexp)

				if method_name(sexp) == :add_breadcrumb
					add_breacrumbs(sexp, options)
				else
					# Check before_action
				end			
			end
		end

		def add_breacrumbs(sexp, only: [], except: [], **conditionals) 
			actions = select_with_only_except(controller_actions, only, except)
			actions.each { |action| add_breacrumb(sexp, action, conditionals: conditionals) }
		end

		def add_breacrumb(sexp, action, conditionals: {})
			array_args = convert_to_source(sexp).gsub('add_breadcrumb(', '').gsub('\'', '').split(', ')[0..1]

			breadcrumbs_controller[action] ||= []
			breadcrumbs_controller[action] << { name: array_args[0], path: array_args[1], view: nil }.merge(conditionals)
		end

		def remove_procs(source)
			source.gsub(/(?:lambda|Proc\.new|proc) { \|(\w+)\| (\(*"?.+?) }\)?/) do
				formated = $2.gsub("#{$1}.", '')
				"'#{formated}'"
			end
		end

		def get_callback_options(sexp)
			options = {}
			source  = convert_to_source(sexp)

			#Search for except and only Array
			source.scan(/:(except|only) => \(\[(?::(.+))\]/) do |type, string_array|
				options[type.to_sym] = string_array.split(', :')
			end

			#Search for if and unless
			source.scan(/:(if|unless) => (?:\('(.+?)'|:(.+?)[\),])/) do |type, proc, symbol|
				options[type.to_sym] = proc || symbol
			end

			options
		end

		def convert_to_source(sexp)
			remove_procs(ruby2ruby.process(sexp.deep_clone).gsub('view_context.', ''))
		end

		def controller_actions
			klass.action_methods.reject{|action| action.start_with? '_' }
		end

		def select_with_only_except(collection, only, except)
			collection.select { |element| (only.empty? || only.include?(element)) && except.exclude?(element) }
		end

		def method_name(sexp)
			sexp[2]
		end
	end
end