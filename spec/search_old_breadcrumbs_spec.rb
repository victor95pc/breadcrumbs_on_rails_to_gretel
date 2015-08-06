require 'spec_helper'

describe BreadcrumbsOnRailsToGretel::SearchOldBreadcrumbs do
	let(:search) do
		described_class.new
	end

	let(:parser) { RubyParser.new }

	let(:negotiation_file_path) { Rails.root.join('app', 'controllers', 'negotiations_controller.rb') }

	describe '#look_all_controllers' do
		before :each do
			allow(search).to receive_messages(
				breadcrumbs_controller:  [{ name: 'Test',  path: 'negotiation_path', view: nil }],
				search_on_class_methods: nil,
				search_on_actions:       nil,
				prepare_controller:      nil
			)
		end

		context 'check one' do
			before :each do 
				one_controller = Rails.root.join('app', 'controllers').children.first
				allow_any_instance_of(Pathname).to receive(:children) { [one_controller] }
			end

			context 'generic controller' do
				before(:each) {search.klass = NegotiationsController}
				it 'call prepare controller' do
					expect(search).to receive(:prepare_controller)
					search.send(:look_all_controllers)
				end

				it 'call search on classes methods' do
					expect(search).to receive(:search_on_class_methods)
					search.send(:look_all_controllers)
				end			
			end

			context 'ApplicationController' do
				before(:each) do 
					search.klass = ApplicationController
					search.send(:look_all_controllers)
				end

				it 'dont include breadcrumbs to breadcrumbs list' do
					expect(search.breadcrumbs).to be_empty
				end

				it 'include breadcrumbs to breadcrumbs root list' do
					expect(search.breadcrumbs_root.count).to eq(1)
				end
			end

			context 'NegotiationsController' do
				before(:each) {search.klass = NegotiationsController}

				it 'include breadcrumbs to breadcrumbs list' do
					search.send(:look_all_controllers)
					expect(search.breadcrumbs[NegotiationsController].count).to eq(1)
				end

				it 'dont include breadcrumbs to breadcrumbs root list' do
					expect { search.send(:look_all_controllers) }.to change{ search.breadcrumbs_root.count }.by(0)
				end

				it 'call search on actions' do
					expect(search).to receive(:search_on_actions)
					search.send(:look_all_controllers)
				end
			end
		end
	end

	context 'private methods' do
		context 'tests with negotiations controller' do
			describe '#prepare_controller' do
				before :each do
					search.send(:prepare_controller, negotiation_file_path)
				end

				it 'get class from sexp' do
					expect(search.klass).to be NegotiationsController
				end

				it 'load controller sexp' do
					expect(search.controller_sexp).to be_any
				end

				it 'should reset found breadcrumbs' do
					expect(search.breadcrumbs_controller).to be_empty
				end
			end

			describe '#search_on_class_methods' do
				before :each do
					allow(search).to receive_messages(
						get_callback_options: nil,
						add_breacrumbs:       nil
					)
					search.send(:prepare_controller, negotiation_file_path)
				end

				it 'get options for two before_filter and one add_breadcrumb' do
					expect(search).to receive(:get_callback_options).exactly(3).times
					search.send(:search_on_class_methods)
				end

				it 'add one breadcrumbs for a bunch of actions' do
					expect(search).to receive(:add_breacrumbs)
					search.send(:search_on_class_methods)
				end
			end

			describe '#add_breacrumbs' do
				it 'add breadcrumb for 8 actions' do
					search.klass = NegotiationsController
					actions = %w(index show new edit create update destroy search_id)
					allow(search).to receive(:select_with_only_except).and_return(actions)
					expect(search).to receive(:add_breacrumb).exactly(8).times
					search.send(:add_breacrumbs, nil)
				end
			end

			describe '#add_breacrumb' do
				it 'add single breadcrumb for new action' do
					search.klass                  = NegotiationsController
					search.breadcrumbs_controller = {}
					sexp = parser.parse 'add_breadcrumb(proc { |c| "Negotiation #{c.params[:type].humanize.pluralize}" }, lambda { |c| c.negotiation_path(c.params[:type]) })'
					
					search.send(:add_breacrumb, sexp, 'new')
					expect(search.breadcrumbs_controller['new'].first).to eq({name: '"Negotiation #{params[:type].humanize.pluralize}"', path: 'negotiation_path(params[:type])', view: nil})
				end
			end

			describe '#remove_procs' do
				it 'simple procs' do
					sexp   = parser.parse 'add_breadcrumb(proc { |c| "Negotiation #{c.params[:type].humanize.pluralize}" }, lambda { |c| c.negotiation_path(c.params[:type]) })'
					source = search.send(:convert_to_source, sexp)

					expect(search.send(:remove_procs, source))
					.to eq('add_breadcrumb(\'"Negotiation #{params[:type].humanize.pluralize}"\', \'negotiation_path(params[:type])\'')
				end

				it 'with == condicional' do
					sexp   = parser.parse 'add_breadcrumb("Negotiations", lambda { |c| c.negotiation_path(c.params[:type]) }, :unless => (lambda { |c| (c.negotiation_path(c.params[:type]) == "accept") }))'
					source = search.send(:convert_to_source, sexp)

					expect(search.send(:remove_procs, source))
					.to eq('add_breadcrumb("Negotiations", \'negotiation_path(params[:type])\', :unless => (\'(negotiation_path(params[:type]) == "accept")\')')
				end
			end

			describe '#get_callback_options' do
				context 'get one options' do
					it 'if' do
						sexp = parser.parse "add_breadcrumb 'Negotiations', -> (c) { c.negotiation_path(c.params[:type]) }, if: :user_logged_in?"
						expect(search.send(:get_callback_options, sexp)).to eq(if: 'user_logged_in?')
					end

					it 'unless' do
						sexp = parser.parse "add_breadcrumb 'Negotiations', -> (c) { c.negotiation_path(c.params[:type]) }, unless: -> (c) { c.negotiation_path(c.params[:type]) == 'accept' }"
						expect(search.send(:get_callback_options, sexp)).to eq(unless: '(negotiation_path(params[:type]) == "accept")')
					end

					it 'only' do
						sexp = parser.parse 'before_filter :show_breadcrumbs, only: [:index]'
						expect(search.send(:get_callback_options, sexp)).to eq(only: %w(index))
					end

					it 'except' do
						sexp = parser.parse 'before_filter :find_negotiation, except: [:create]'
						expect(search.send(:get_callback_options, sexp)).to eq(except: %w(create))
					end
				end
			end

		end
	end
end
