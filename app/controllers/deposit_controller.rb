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
    api = PayPal::SDK::Merchant::API.new

    # Build request object
    request_object = checkout_builder(@goal.occurrence)
    
    # Make API call & get response
    response = api.set_express_checkout(request_object)
    
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
      api = PayPal::SDK::Merchant::API.new
      
      raise 'Deposit was already made.' unless @goal.deposit.blank?
      
      @deposit = @goal.build_deposit user: current_user, token: params[:token], payer_id: params[:PayerID], amount: @goal.occurrence, source: 'paypal'
      
      checkout_object = api.build_do_express_checkout_payment({
                                                                :DoExpressCheckoutPaymentRequestDetails => {
                                                                  :PaymentAction => "Sale",
                                                                  :Token => @deposit.token,
                                                                  :PayerID => @deposit.payer_id,
                                                                  :PaymentDetails => [{
                                                                                        :OrderTotal => {
                                                                                          :currencyID => "USD",
                                                                                          :value => @deposit.amount.to_param 
                                                                                        }
                                                                                      }]
                                                                }
                                                              })

      # Make API call & get response
      @checkout_response = api.do_express_checkout_payment(checkout_object)
      
      raise 'Paypal payment failed.' unless @checkout_response.success?

      transaction_id = @checkout_response.DoExpressCheckoutPaymentResponseDetails.PaymentInfo[0].TransactionID

      @deposit.transaction_id = transaction_id
      @deposit.save!

      flash[:notice] = 'The deposit was made successfully. Now your goal is active!'
      @redirecter = user_goal_url(current_user, @goal)
    rescue => error
      flash.now[:alert] = error
      render 'error' 
    end
  end
  
  
  def refund
    unless @goal.deposit.refund?
      flash[:alert] = 'The goal is not completed yet.'
      
      redirect_to user_goal_path(current_user, @goal) and return
    end
    
    @deposit = @goal.deposit
    
    @deposit.notification.destroy! unless @deposit.notification.blank?
    
    if request.post?
      api = PayPal::SDK::Merchant::API.new
      
      refund = @goal.commits.succeed.size
      
      if (Time.now.utc - @deposit.created_at) > 60.days # Masspay
        mass_pay = api.build_mass_pay({
          :ReceiverType => "EmailAddress",
          :MassPayItem => [{
            :ReceiverEmail => @deposit.payer,
            :Amount => {
              :currencyID => "USD",
              :value => refund } }] })
        
        mass_pay_response = api.mass_pay(mass_pay)
        
        if mass_pay_response.success?
          @deposit.completed!
          
          flash[:notice] = 'Transfer request is acceptted by Paypal.'
          redirect_to deposit_index_path
        else
          flash.now[:alert] = mass_pay_response.Errors[0].LongMessage
        end
      else # Refund
        refund_transaction = api.build_refund_transaction({
          :TransactionID => @deposit.transaction_id,
          :RefundType => @deposit.amount > refund ? 'Partial' : 'Full',
          :Amount => {
            :currencyID => "USD",
            :value => refund },
          :RefundSource => "default" })
        
        refund_response = api.refund_transaction(refund_transaction)
        
        if refund_response.success?
          @deposit.completed!
          
          flash[:notice] = 'Refund request is acceptted by Paypal.'
          redirect_to deposit_index_path
        else
          flash.now[:alert] = refund_response.Errors[0].LongMessage
        end
      end
    end
  end
  
  
  
  private
  def get_my_goal
    @goal = current_user.goals.find_by_slug(params[:goal_id])
  end

  def checkout_builder(occurrence)
    @api = PayPal::SDK::Merchant::API.new

    # Build request object
    @api.build_set_express_checkout(
      {
        SetExpressCheckoutRequestDetails: {
          ReturnURL: confirm_goal_deposit_index_url(@goal),
          CancelURL: cancel_goal_deposit_index_url(@goal),
          PaymentDetails: [{
                             OrderTotal: {
                               currencyID: "USD",
                               value: "#{ occurrence }.00"
                             },
                             PaymentDetailsItem: [{
                                                    Name: "One dollar deposit per day",
                                                    Quantity: "#{ occurrence }",
                                                    Amount: {
                                                      currencyID: "USD",
                                                      value: "1.00" },
                             ItemCategory: "Digital" }],
        PaymentAction: "Sale" }] }
    })
  end
end
