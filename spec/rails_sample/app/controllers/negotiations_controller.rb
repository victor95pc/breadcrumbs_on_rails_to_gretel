class NegotiationsController < ApplicationController

  
  before_filter :show_breadcrumbs
  before_filter :find_negotiation, except: [:create]

  add_breadcrumb proc {|c| "Negotiation #{c.params[:type].humanize.pluralize}" }, -> (c) { c.negotiation_path(c.params[:type]) }

  def index
    @negotiations = apply_scopes(Negotiation).page(params[:page])
  end

  def show
    add_breadcrumb 'Show Negotiation'
  end

  def new
    add_breadcrumb 'New Negotiation'
  end

  def edit
    add_breadcrumb 'Edit Negotiation'
  end

  def create
    @negotiation = Negotiation.new(negotiation_params)
    if @negotiation.save
      redirect_to :index, notice: 'Negotiation was saved'
    else
      render :new
    end
  end

  def update
    if @negotiation.update_attributes(negotiation_params)
      redirect_to :index, notice: 'Negotiation updated.'
    else
      render :edit
    end
  end

  def destroy
    @negotiation.destroy
    redirect_to :index, notice: 'Negotiation removed.'
  end

  def search_id
    add_breadcrumb 'Search ID', :search_id_negotiation_path
  end

  private

  def find_negotiation
    @negotiation = params[:id].present? ? Negotiation.find(params[:id]) : Negotiation.new
  end

  def show_breadcrumbs
    if params[:type] == 'lovely negotiation'
      add_breadcrumb "Good Negotiation"
    end
  end

  def negotiation_params
    params.require(:negotiation).permit! # It was a quick translation ;)
  end
end