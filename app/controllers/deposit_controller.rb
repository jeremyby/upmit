class DepositController < ApplicationController
  before_action :authenticate_user!
  before_action :get_my_goal, only: [:new, :create, :confirm]
  
  layout 'payment', except: [:index, :new]

  def index

  end
  
  def cancel
    render 'error'
  end
  
  def new
    @deposit = @goal.build_deposit(user: current_user)
  end

  def create
    api = PayPal::SDK::Merchant::API.new

    # Build request object
    request_object = checkout_builder(@goal.occurrence)

    # Make API call & get response
    response = api.set_express_checkout(request_object)

    # Access Response
    if response.success?
      redirect_to "https://www.sandbox.paypal.com/incontext?useraction=commit&token=#{ response.Token }"
    else
      flash[:error] = response.Errors.inspect
      render 'error'
    end
  end

  def confirm
    begin
      api = PayPal::SDK::Merchant::API.new
      
      raise 'Deposit was already made.' unless @goal.deposit.blank?
      
      @deposit = @goal.build_deposit(user: current_user, token: params[:token], payer: params[:PayerID], amount: @goal.occurrence, source: 'paypal')

      checkout_object = api.build_do_express_checkout_payment({
                                                                :DoExpressCheckoutPaymentRequestDetails => {
                                                                  :PaymentAction => "Sale",
                                                                  :Token => @deposit.token,
                                                                  :PayerID => @deposit.payer,
                                                                  :PaymentDetails => [{
                                                                                        :OrderTotal => {
                                                                                          :currencyID => "USD",
                                                                                          :value => @goal.occurrence 
                                                                                        }
                                                                                      }]
                                                                }
                                                              })

      # Make API call & get response
      @checkout_response = api.do_express_checkout_payment(checkout_object)
      
      raise 'Paypal payment failed.' unless @checkout_response.success?

      # checkout_response.DoExpressCheckoutPaymentResponseDetails
      # checkout_response.FMFDetails

      @deposit.save!
    
      flash[:alert] = 'You have made the deposit. The goal is active now!'
      @redirecter = goal_url(@goal)
    rescue => error
      flash[:error] = error
      render 'error' 
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
                               value: "#{ occurrence }"
                             },
                             PaymentDetailsItem: [{
                                                    Name: "One Dollar Deposit",
                                                    Quantity: "#{ occurrence }",
                                                    Amount: {
                                                      currencyID: "USD",
                                                    value: "1" },
                             ItemCategory: "Digital" }],
        PaymentAction: "Sale" }] }
    })
  end
end
