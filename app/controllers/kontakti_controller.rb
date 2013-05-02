class KontaktiController < ApplicationController
  def initialize
    @active_tab = '/kontakti'
    super
  end

  def index
    @kontakti = Kontakt.paginate({:per_page => 15, :page => params[:page] })
  end

  def new
    @kontakt = Kontakt.new
    render :edit
  end

  def search
    @kontakti = Kontakt.paginate_solr(params[:q], {:per_page => 15, :page => params[:page] })
    render :index 
  end

  def show
    @kontakt = Kontakt.find(params[:id])
  end

  def edit
    @kontakt = Kontakt.find(params[:id])
  end

  def create
    @kontakt = Kontakt.new(params[:kontakt])
    render_create_update(@kontakt.save, "Korisnik je uspjesno dodan")
  end


  def update
    @kontakt = Kontakt.find(params[:id])
    render_create_update(@kontakt.update_attributes(params[:kontakt]), "Kontakt je uspjesno izmijenjen") 
  end

  def render_create_update(success, message)
    respond_to do |format|
      if success
        format.js { render :json => { :data => { :kontakt => @kontakt.attributes } , :flash => message} }
      else
        @item = @kontakt
        format.js { render :json => { :html_error => errors_for(@kontakt), :errors => @kontakt.errors } }
      end
    end
  end

  def destroy
    @kontakt = Kontakt.find(params[:id])
    @kontakt.destroy
    redirect_to("/kontakti")
  end
end
