#coding: utf-8
class UsersController < ApplicationController
  layout "merepresentalogged"

  inherit_resources
  load_and_authorize_resource

  # Se existir um candidato para o usuário, vai carregar também
  # Leva em consideração que o ID do candidato = ID do usuário
#  before_filter only:[:edit] do
#    if defined?(@candidate).nil?
#      if Candidate.exists? @user.id
#        @candidate = Candidate.find @user.id
#      else
#        @candidate = flash[:candidate] # Se houve erro, será retornado aqui (Edição anterior)
#
#        if @candidate == nil # Caso não seja erro, precisamos de dados novos para serem utilizados
#          @candidate = Candidate.new
#          @candidate.name = @user.name
#          @candidate.email = @user.email
#          @candidate.mobile_phone = @user.mobile_phone
#          @candidate.city_id = @user.city_id
#        end
#      end
#    end
#  end


  before_filter :load_all_cities, only:[:edit]

  def index
    authorize! :export, @current_user if params[:format] == "csv"
    respond_to do |format|
      format.csv { render :layout => false }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to params[:redirect_to] || new_answer_path }
      failure.html
    end
  end

  def matchup
    @user = User.find params[:user_id]
    if @user.answers.select{|a| a.weight >0 }.count == 0
      redirect_to city_candidates_path(@user.city)
      return
    end
    if params[:first] 
      @matching = @user.matches params[:first] 
    else
      @matching = @user.matches
      if @matching.count == 0
        redirect_to city_convine_path(@user.city)
        return
      end
    end
    respond_to do |format|
      format.html 
      format.json {
        render :json => @matching
      }
    end
  end

  private

  def load_all_cities
    @cities = City.cities_for_select
  end
end
