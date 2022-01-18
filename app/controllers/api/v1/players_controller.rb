class Api::V1::PlayersController < Api::V1::BaseController
  before_action :set_player, only: [ :show, :update, :destroy ]

  def index
    @players = Player.all
  end

  def show
  end

  def update
    if @player.update(player_params)
      render :show
    else
      render_error
    end
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      render :show, status: :created
    else
      render_error
    end
  end

  def destroy
    @player.destroy
    head :no_content
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:nickname, :avatar, :status, :ranking)
  end

  def render_error
    render json: { errors: @player.errors.full_messages },
      status: :unprocessable_entity
  end

end