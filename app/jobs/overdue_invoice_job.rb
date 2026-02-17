class OverdueInvoiceJob < ApplicationJob
  queue_as :default

  def perform
    overdue = Invoice.where(status: :sent)
                     .where("due_date < ?", Date.current)
    overdue.find_each do |invoice|
      invoice.update!(status: :overdue)
      Notifications::DispatchService.call(
        recipient: invoice.patient,
        action: "invoice_overdue",
        title: "Invoice Overdue",
        body: "Invoice #{invoice.invoice_number} is overdue. Please make payment.",
        notifiable: invoice
      )
    end
  end
end
