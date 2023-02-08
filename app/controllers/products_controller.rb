class ProductsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_product, only: %i[ show update destroy ]
  before_action :check_permission_on_product, only: %i[ update destroy ]
  before_action :check_seller_permission, only: %i[ create ]

  # GET /products
  def index
    @products = Product.all

    render json: @products
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params.to_h.merge(seller_id: current_user.id))

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params.to_h.merge(seller_id: current_user.id))
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.fetch(:product, {}).permit(:amount_available, :cost, :product_name)
    end

    def authorized_product_creator?
      return @product&.seller_id == current_user&.id
    end

    def check_permission_on_product
      render json: {message: "Unauthorized"}, status: 401 unless authorized_product_creator?
    end

    def check_seller_permission
      render json: {message: "Unauthorized"}, status: 401 unless current_user.role == "seller"
    end
end
