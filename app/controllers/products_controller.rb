class ProductsController < ApplicationController
  before_action :load_category, only: %i(index)
  before_action :load_product, except: %i(index create new)
  before_action :load_all_category, only: %i(new edit show)

  def new
    @product = Product.new
  end

  def create
    @product = Product.new product_params
    if @product.save
      flash[:success] = t ".add_success"
      redirect_to products_manager_path
    else
      render :new
    end
  end

  def destroy
    if @product.destroy
      flash[:success] = t ".destroy_success"
    else
      flash[:danger] = t ".destroy_fail"
    end
    redirect_to products_manager_path
  end

  def edit; end

  def update
    if @product.update_attributes(product_params)
      flash[:success] = t "updated"
      redirect_to products_manager_path
    else
      render :edit
    end
  end

  def show
    @comments = @product.comments.sort_by_time.paginate(page: params[:page],
      per_page: Settings.paginate.comment_perpage)
    @comment = current_user.comments.build if logged_in?
  end

  def index
    @products = if @category
      @category.products
    else
      Product.search_by_price select_price
    end.search_by_name(params[:search]).sort_by_name
  end

  private

  def load_product
    @product = Product.find_by id: params[:id]
    return if @product
    flash[:danger] = t "cant_find_product"
    redirect_to root_url
  end

  def load_category
    unless params[:category].nil?
      @category = Category.find_by name: params[:category]
      return if @category
      render file: "public/404.html"
    end
  end

  def select_price
    if params[:reson].present?
      return if params[:reson][:price] == Settings.controllers.products.all
      start, last = params[:reson][:price].split(Settings.controllers.products.to)
      start..last
    end
  end

  def product_params
    params.require(:product).permit :name, :price, :quantity, :active, :picture, :category_id
  end
end
