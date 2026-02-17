module Billing
  class InvoiceGeneratorService < ApplicationService
    def initialize(visit:, items: [])
      @visit = visit
      @items = items
    end

    def call
      invoice = Invoice.new(
        patient: @visit.patient,
        visit: @visit,
        due_date: Date.current + 30.days,
        status: :draft
      )

      @items.each do |item_attrs|
        invoice.invoice_items.build(item_attrs)
      end

      # Auto-add services from visit's appointment if present
      if @visit.appointment&.service.present?
        svc = @visit.appointment.service
        invoice.invoice_items.build(
          service: svc,
          description: svc.name,
          quantity: 1,
          unit_price_cents: svc.price_cents
        ) unless @items.any?
      end

      if invoice.save
        Result.new(success?: true, data: invoice)
      else
        Result.new(success?: false, error: invoice.errors.full_messages.join(", "))
      end
    rescue => e
      Result.new(success?: false, error: e.message)
    end
  end
end
