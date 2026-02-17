module ApplicationHelper
  include Pagy::Frontend

  def page_title(title = nil)
    base = "Healthroom"
    title.present? ? "#{title} | #{base}" : base
  end

  def format_naira(amount_cents)
    return "₦0.00" if amount_cents.nil? || amount_cents.zero?
    "₦#{number_with_delimiter(amount_cents / 100.0, delimiter: ',')}"
  end

  def avatar_for(user, size: "w-10 h-10", text_size: "text-sm")
    if user.avatar.attached?
      image_tag user.avatar.variant(resize_to_limit: [ 100, 100 ]),
                class: "#{size} rounded-full object-cover",
                alt: user.full_name
    else
      content_tag :div, user.initials,
                  class: "#{size} rounded-full bg-primary text-primary-content flex items-center justify-center font-bold #{text_size}"
    end
  end

  def role_badge(role)
    colors = {
      "admin" => "badge-error",
      "doctor" => "badge-primary",
      "nurse" => "badge-secondary",
      "receptionist" => "badge-accent",
      "patient" => "badge-info"
    }
    content_tag :span, role.capitalize, class: "badge #{colors[role]} badge-sm"
  end

  def status_badge(status, type: :default)
    colors = case type
    when :appointment
      { "pending" => "badge-warning", "confirmed" => "badge-info", "checked_in" => "badge-accent",
        "in_progress" => "badge-primary", "completed" => "badge-success", "cancelled" => "badge-error", "no_show" => "badge-ghost" }
    when :invoice
      { "draft" => "badge-ghost", "sent" => "badge-info", "partially_paid" => "badge-warning",
        "paid" => "badge-success", "overdue" => "badge-error", "cancelled" => "badge-ghost" }
    else
      { "active" => "badge-success", "inactive" => "badge-ghost", "true" => "badge-success", "false" => "badge-ghost" }
    end
    css = colors[status.to_s] || "badge-ghost"
    content_tag :span, status.to_s.humanize, class: "badge #{css} badge-sm"
  end
end
