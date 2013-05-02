

class PoliceController < ApplicationController
  layout :default_or_ajax
  
  def initialize
    @active_tab = '/police'
  end
  # GET /police
  # GET /police.xml
  def index
    @police = Polica.all
    @cjenici = Cjenik.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @police }
    end
  end

  # GET /police/1
  # GET /police/1.xml
  def show
    @polica = Polica.find(params[:id])
    @schema = Schema.new(params[:cjenik])
    render :template => 'police/new.html.erb'
  end

  # GET /police/new
  # GET /police/new.xml
  def new
    @polica = Polica.new
    @schema = Schema.new(params[:cjenik])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @polica }
    end
  end

  # GET /police/1/edit
  def edit
    @polica = Polica.find(params[:id])
    @schema = Schema.new(params[:cjenik])
    render :template => 'police/new.html.erb'
  end

  # POST /police
  # POST /police.xml values[@name] = @value = @value.round(2) if result 
  def create
    @polica = Polica.new(params[:polica])


    @osiguranja = Array.new
    if params[:osiguranje] != nil
      params[:osiguranje][:postavke].each do |item|
        deser = ActiveSupport::JSON.decode(item)
        osiguranje = Osiguranje.new
        osiguranje.postavke = Hash.new
        deser.each do |token|
          if token["name"] =~ /stavka\[(.*)\]/
            osiguranje.postavke[$1] = token["value"] 
          end
        end
        @osiguranja << osiguranje
      end
    end

    Polica.transaction do
      @polica.save!
      @osiguranja.each do |item|
        item.polica = @polica
        item.save
      end
      flash[:notice] = 'Polica was successfully created.'
      redirect_to(@polica)
    end
  end

  # PUT /police/1 values[@name] = @value = @value.round(2) if result 
  # PUT /police/1.xml
  def update
    @polica = Polica.find(params[:id])

    respond_to do |format|
      if @polica.update_attributes(params[:polica])
        flash[:notice] = 'Polica was successfully updated.'
        format.html { redirect_to(@polica) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @polica.errors, :status => :unprocessable_entity }
      end
    end

  end

  # DELETE /police/1
  # DELETE /police/1.xml
  def destroy
    @polica = Polica.find(params[:id])
    @polica.destroy

    respond_to do |format|
      format.html { redirect_to(police_url) }
      format.xml  { head :ok }
    end
  end
      
  def nova_stavka
    @active_tab = '/police'
    @stavka =  OpenStruct.new(cjenik.defaults)
  end

  def cjenik
    @cjenik ||= Cjenik.instanca(params[:osiguranje], params[:grupa])
  end
  
  # procitaj postavke sa forme
  def postavke
    return @postavke if !@postavke.nil? 
    @postavke = {}
    cjenik.premijska_grupa.descendants.each do |node|
        @postavke[node.name.to_sym] = params[:stavka][node.name] if params[:stavka] != nil && params[:stavka][node.name] != '' 
    end
    return @postavke
  end

  def get_polica
    @polica ||= Polica.new().dodaj_stavke(params[:osiguranje], params[:grupa], postavke)
  end

  def osvjezi_stavku
    ret = []
    cjenik.premijska_grupa.visibility_list(postavke).each_pair do |key, value|
      ret << { :name => key, :visible =>  value.visible, :default_value => value.default_value}
    end  
    if (cjenik.validate(postavke).ok? == true)
      ret << { :name => 'stavka_iznos_premije', :text => to_c(get_polica.premija) }
    end
    pp ret
    render :content_type => :js, :text => ret.to_json
  end

  def stavka_osiguranja
    @stavke = get_polica.stavke
  end

  def validiraj_stavku
    render :content_type => :js, :text => cjenik.validate(postavke).to_json
  end

end

