class DepositController < ApplicationController
  before_action :authenticate_user!
  before_action :get_my_goal, only: [:new, :create, :confirm, :refund]

  layout 'payment', except: [:index, :new, :refund]

  def index

  end

  def cancel
    render 'error'
  end

  def new
    if @goal.deposit.blank?
      @deposit = @goal.build_deposit(user: current_user)
    else
      flash[:notice] = 'Deposit was already made.'
      redirect_to user_goal_path(current_user, @goal)
    end
  end

  def create
    return_url = confirm_goal_deposit_index_url(@goal)
    cancel_url = cancel_goal_deposit_index_url(@goal)

    # Make API call & get response
    response = Deposit.set_checkout_for(@goal, return_url, cancel_url)

    # raise response.inspect

    # Access Response
    if response.success?
      if Rails.env.development?
        redirect_to "https://www.sandbox.paypal.com/incontext?useraction=commit&token=#{ response.Token }"
      else
        redirect_to "https://www.paypal.com/incontext?useraction=commit&token=#{ response.Token }"
      end
    else
      render 'error'
    end
  end

  def confirm
    begin
      raise 'Deposit was already made.' unless @goal.deposit.blank?

      @deposit = @goal.build_deposit user: current_user, token: params[:token], payer_id: params[:PayerID], amount: @goal.occurrence, source: 'paypal'

      response = @deposit.express_checkout

      raise 'Paypal payment failed.' unless response.success?

      @deposit.transaction_id = response.DoExpressCheckoutPaymentResponseDetails.PaymentInfo[0].TransactionID

      @deposit.save!

      flash[:notice] = 'The deposit was made successfully. Now your goal is activated!'
      @redirecter = user_goal_url(current_user, @goal)
    rescue => error
      flash.now[:alert] = error || response.Errors[0].LongMessage
      render 'error'
    end
  end

  def refund
    unless @goal.deposit.refund?
      flash[:alert] = 'The goal is not completed yet.'

      redirect_to user_goal_path(current_user, @goal) and return
    end

    @deposit = @goal.deposit

    if request.post?
      refund = @goal.commits.succeed.size

      if (Time.now.utc - @deposit.created_at) > 60.days # Masspay
        response = @deposit.make_mass_pay(refund)
      else                                              # Refund
        response = @deposit.make_refund(refund)
      end

      if response.success?
        @deposit.notification.destroy! unless @deposit.notification.blank?
        
        @deposit.completed!

        flash[:notice] = 'The request to refund was acceptted by Paypal. Please check your Paypal account or credit/debit card in a while.'
        redirect_to deposit_index_path
      else
        flash.now[:alert] = response.Errors[0].LongMessage
      end
    end
  end


  private
  def get_my_goal
    @goal = current_user.goals.find_by_slug(params[:goal_id])
  end
end
