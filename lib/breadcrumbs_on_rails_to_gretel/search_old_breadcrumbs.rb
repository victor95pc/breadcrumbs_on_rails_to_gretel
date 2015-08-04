module BreadcrumbsOnRailsToGretel
	class SearchOldBreadcrumbs
		attr_accessor :breadcrumbs, :breadcrumbs_controller, :parser, :ruby2ruby, :controller_sexp, :klass

		def initialize(path: %w(app controllers))
			self.parser      = RubyParser.new
			self.ruby2ruby   = Ruby2Ruby.new
			self.breadcrumbs = []

			Rails.root.join(*path).each_child do |file| 
				prepare_controller(file)
				search_on_class_methods
				search_on_actions
				breadcrumbs[klass] << breadcrumbs_controller
			end
		end

		private

		def prepare_controller(file)
			self.breadcrumbs_controller = {}
			self.controller_sexp        = parser.process(File.open(file).read)

			self.klass = Kernel.const_get controller_sexp[1]
		end

		def search_on_class_methods
			controller_sexp.find_nodes(:call).select {|sexp| /(before_(?:action|filter)|add_breadcrumb)/ === method_name(sexp) }.each do |sexp|
				
				options = get_callback_options(sexp)

				if method_name(sexp) == :add_breadcrumb
					add_breacrumbs(sexp, options)
				else


				end			
			end
		end

		def search_on_actions
			
		end

		checkbreadcrumb

		def add_breacrumbs(sexp, only: nil, except: nil, **conditionals) 
			actions = select_with_only_except(controller_actions, only, except)
			actions.each { |action| add_breacrumb(sexp, action, callback_ops) }
		end

		def add_breacrumb(sexp, action, conditionals)
			source = remove_procs(convert_to_source(sexp).gsub('view_context.', '')) 
			
			source.scan(/add_breadcrumb\((".+?"),?\s?[:']?(.+)?/) do |name, path| 
				breadcrumbs_controller[action] ||= []
				breadcrumbs_controller[action] << {name: name, path: path.chop, view: nil }.merge conditionals]
				breadcrumbs_controller[action] << {name: name, path: path.chop, view: nil }.merge conditionals]
			end
		end

		def remove_procs(source)
			source.gsub(/(?:lambda|Proc\.new|proc) { \|(\w)\| ("?.+?) }/) { $2.gsub("#{$1}.", '') }
		end

		def get_callback_options(sexp)
			options = {}
			source  = convert_to_source(sexp)

			#Search for except and only Array
			source.scan(/:(except|only) => \(\[(?::(.+))\]/) do |type, string_array|
				options[type.to_sym] = string_array.split(', :')
			end

			#Search for if and unless
			remove_procs(source).scan(/:(if|unless) => [:"](.+?)[",\s]/) do |type, block|
				options[type.to_sym] = block
			end

			options
		end

		def convert_to_source(sexp)
			ruby2ruby.process(sexp.deep_clone)
		end

		def controller_actions
			klass.action_methods.reject{|action| action.start_with? '_' }
		end

		def select_with_only_except(collection, only=[], except=[])
			collection.select { |element| (only.empty? || only.include?(element)) && except.exclude?(element) }
		end

		def method_name(sexp)
			sexp[2]
		end
	end
end