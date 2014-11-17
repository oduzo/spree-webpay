class WebpayWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  sidekiq_options :queue => :webpay

  def perform payment_id, state
    puts "#{payment_id} - #{state}"
    payment = Spree::Payment.find payment_id
    return unless payment
    order = payment.order

    begin
      if state == "accepted"
        payment.started_processing!
        payment.capture!
        order.next! unless order.state == "completed"
      elsif state == "rejected"
        payment.started_processing!
        payment.failure!
      end
    rescue Exception => e
      Rails.logger.error("Error al procesar pago orden #{order.number}: E -> #{e.message}")
    end
  end

end