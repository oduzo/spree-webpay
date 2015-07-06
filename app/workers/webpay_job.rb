class WebpayJob < ActiveJob::Base
  queue_as :webpay

  def perform payment_id, state
    payment = Spree::Payment.find payment_id
    return unless payment
    begin
      if state == "accepted"
        payment.capture!
        payment.order.next! unless payment.order.complete?
        payment.order.reload
      elsif state == "rejected"
        payment.failure!
      end
    rescue => e
      puts e.message
      Rails.logger.error("Error al procesar pago orden #{payment.order.number}: E -> #{e.message}")
    ensure
      payment.order.save!
    end
  end

end