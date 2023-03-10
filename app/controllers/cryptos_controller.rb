class CryptosController < ApplicationController
  before_action :set_crypto, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :correct_user, only: %i[ edit update destroy show ]
  # GET /cryptos or /cryptos.json
  def index
    @portfos = Portfo.all
    @cryptos = Crypto.all
    require 'net/http'
    require 'json'
    @url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?CMC_PRO_API_KEY=fd04676f-2762-4500-9f39-c0290aa0c3c8&start=1&limit=100&convert=USD'
    @uri = URI(@url)
    @response = Net::HTTP.get(@uri)
    @lookup_crypto = JSON.parse(@response)
    @profit_loss = 0
    @cryptos.each do |crypto|
      if crypto.user_id == current_user.id
        if crypto.symbol
          crypto.symbol = crypto.symbol.upcase
        end
          for x in @lookup_crypto['data']
            if crypto.symbol == x['symbol']
      current_price = x['quote']['USD']['price'].to_d * crypto.amount_owned
      total_paid = crypto.cost_per * crypto.amount_owned
      @profit_loss += current_price - total_paid
            end
          end
      end
    end
    #Tao 1 record portfo moi, truoc do phai tao model cho portfo
    Portfo.create(profit: @profit_loss,
      user_id: current_user.id,
      created_at: Time.now,
      updated_at: Time.now)
    #tao data cho chart portfo
      @data_chart = JSON.parse(Portfo.all.to_json(:only =>[:created_at,:profit])) 
      @data_chart_result = Hash.new

      @data_chart.each do |a|
        c = a.values
        @data_chart_result["#{c[1]}"] = c[0]
      end
  end
  
  def data #tao controller cho /cryptos/data, noi luu tru json portfo
    @data_chart = Portfo.all.to_json(:only =>[:created_at,:profit, :user_id, :updated_at])
    
    render json: JSON.parse(@data_chart)
  end

  def data_crypto
    @data_crypto = Crypto.all.to_json
    render json: JSON.parse(@data_crypto)
  end



  # GET /cryptos/1 or /cryptos/1.json
  def show
  end

  # GET /cryptos/new
  def new
    @crypto = Crypto.new
  end

  # GET /cryptos/1/edit
  def edit
  end

  # POST /cryptos or /cryptos.json
  def create
    @crypto = Crypto.new(crypto_params)

    respond_to do |format|
      if @crypto.save
        format.html { redirect_to crypto_url(@crypto), notice: "Crypto was successfully created." }
        format.json { render :show, status: :created, location: @crypto }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @crypto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cryptos/1 or /cryptos/1.json
  def update
    respond_to do |format|
      if @crypto.update(crypto_params)
        format.html { redirect_to crypto_url(@crypto), notice: "Crypto was successfully updated." }
        format.json { render :show, status: :ok, location: @crypto }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @crypto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cryptos/1 or /cryptos/1.json
  def destroy
    @crypto.destroy

    respond_to do |format|
      format.html { redirect_to cryptos_url, notice: "Crypto was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_crypto
      @crypto = Crypto.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def crypto_params
      params.require(:crypto).permit(:symbol, :user_id, :cost_per, :amount_owned)
    end
    def correct_user
      @correct = current_user.cryptos.find_by(id: params[:id])
      redirect_to cryptos_path, notice: "Not Authorized to edit this entry" if @correct.nil?
      
    end
end
