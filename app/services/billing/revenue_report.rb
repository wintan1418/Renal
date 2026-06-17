module Billing
  # Revenue-cycle analytics computed from invoices, payments and claims.
  class RevenueReport < ApplicationService
    def call
      {
        kpis: kpis,
        monthly: monthly_collections,
        aging: ar_aging,
        by_status: invoices_by_status,
        by_method: payments_by_method,
        top_debtors: top_debtors,
        claims: claims_summary
      }
    end

    private

    def successful_payments
      @successful_payments ||= Payment.status_successful
    end

    def billable_invoices
      Invoice.where.not(status: [ :draft, :cancelled ])
    end

    def outstanding_scope
      billable_invoices.where("total_cents > amount_paid_cents")
    end

    def kpis
      invoiced = billable_invoices.sum(:total_cents)
      collected = successful_payments.sum(:amount_cents)
      outstanding = outstanding_scope.sum("total_cents - amount_paid_cents")
      overdue = outstanding_scope.where(status: :overdue).sum("total_cents - amount_paid_cents")
      {
        invoiced_cents: invoiced,
        collected_cents: collected,
        outstanding_cents: outstanding,
        overdue_cents: overdue,
        collection_rate: invoiced.positive? ? ((collected.to_f / invoiced) * 100).round : 0,
        paid_invoices: billable_invoices.where(status: :paid).count,
        open_invoices: outstanding_scope.count
      }
    end

    def monthly_collections
      successful_payments
        .where("payments.created_at >= ?", 6.months.ago.beginning_of_month)
        .group_by_month("payments.created_at", format: "%b %Y")
        .sum(:amount_cents)
        .transform_values { |c| (c / 100.0).round }
    end

    # Accounts-receivable aging buckets on outstanding balance, by due date.
    def ar_aging
      buckets = { "Current" => 0, "1–30 days" => 0, "31–60 days" => 0, "61–90 days" => 0, "90+ days" => 0 }
      today = Date.current
      outstanding_scope.find_each do |inv|
        bal = inv.total_cents - inv.amount_paid_cents
        ref = inv.due_date || inv.created_at.to_date
        days = (today - ref).to_i
        key = if days <= 0 then "Current"
        elsif days <= 30 then "1–30 days"
        elsif days <= 60 then "31–60 days"
        elsif days <= 90 then "61–90 days"
        else "90+ days"
        end
        buckets[key] += bal
      end
      buckets.transform_values { |c| (c / 100.0).round }
    end

    def invoices_by_status
      billable_invoices.group(:status).sum(:total_cents).transform_keys(&:humanize).transform_values { |c| (c / 100.0).round }
    end

    def payments_by_method
      successful_payments.group(:payment_method).sum(:amount_cents).transform_keys(&:humanize).transform_values { |c| (c / 100.0).round }
    end

    def top_debtors(limit: 8)
      outstanding_scope
        .group(:patient_id)
        .sum("total_cents - amount_paid_cents")
        .sort_by { |_, v| -v }
        .first(limit)
        .map { |patient_id, bal| { patient: User.find_by(id: patient_id), balance_cents: bal } }
        .reject { |r| r[:patient].nil? }
    end

    def claims_summary
      {
        count: InsuranceClaim.count,
        by_status: InsuranceClaim.group(:status).count.transform_keys(&:humanize),
        outstanding_cents: InsuranceClaim.where(status: [ :submitted, :under_review ]).sum(:claim_amount_cents)
      }
    end
  end
end
