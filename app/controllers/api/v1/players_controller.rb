class Api::V1::PlayersController < Api::V1::BaseController
  before_action :set_player, only: [ :show, :update, :destroy ]

  def index
    if params[:query].present?
      num_regex = /^ *\d[\d ]*$/
      if params[:query].match?(num_regex)
        sql_query = 'players.id LIKE :query'
        @players = Player.where(sql_query, query: params[:query])
      else
        query = " \
          players.nickname LIKE :query \
          OR players.status LIKE :query \
        "
        @players = Player.where(query, query: "%#{params[:query]}%").order('ranking DESC')
      end
    elsif params[:status].present? & params[:ranking].present?
      @players = Player.filter_by_status(status: params[:status]).order_per_ranking(ranking: params[:ranking])
    elsif params[:status].present?
      @players = Player.filter_by_status(status: params[:status])
    elsif params[:ranking].present?
      @players = Player.order_per_ranking(ranking: params[:ranking])
    else
      @players = Player.all
    end
    paginated_players(@players)
  end

  def paginated_players(players)
    # byebug
    # @players = Player.all
    @paginated_players = players.paginate(page: params[:page], per_page: 20) 
    render json: {
      players: @paginated_players,
      current: @paginated_players.current_page,
      page_count: @paginated_players.total_pages
    }
  end

  def hall
    limit_players = 10
    @players = Player.all.where(status: "oro").limit(limit_players).order("ranking DESC")
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
      render json: @player
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

  def filtering_params(params)
    params.slice(:status, :ranking, :query, :page)
  end

  def render_error
    render json: { errors: @player.errors.full_messages }, status: :unprocessable_entity
  end
end
