module ApplicationHelper
  include Pagy::Frontend

  def page_title(title = nil)
    base = "Healthroom"
    title.present? ? "#{title} | #{base}" : base
  end

  # Demo accounts shown as one-click sign-in buttons on the login page so a
  # client can explore every role. All use the seeded demo password.
  # NOTE: for the Admin button to work in production, keep the admin on the
  # demo password (i.e. do not set ADMIN_PASSWORD, or set it to "password123").
  def demo_accounts
    pw = "password123"
    [
      { role: "Admin",     name: "System Admin",       email: "admin@healthroom.ng",          password: pw, badge: "A",  color: "bg-neutral" },
      { role: "Doctor",    name: "Dr. Adaeze Okonkwo", email: "adaeze.okonkwo@healthroom.ng", password: pw, badge: "Dr", color: "bg-primary" },
      { role: "Nurse 1",   name: "Grace Johnson",      email: "nurse.johnson@healthroom.ng",  password: pw, badge: "N1", color: "bg-secondary" },
      { role: "Nurse 2",   name: "Aminu Ibrahim",      email: "aminu.ibrahim@healthroom.ng",  password: pw, badge: "N2", color: "bg-secondary" },
      { role: "Patient 1", name: "Tunde Bakare",       email: "patient@healthroom.ng",        password: pw, badge: "P1", color: "bg-accent" },
      { role: "Patient 2", name: "Ngozi Obi",          email: "ngozi.obi@healthroom.ng",      password: pw, badge: "P2", color: "bg-accent" }
    ]
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

  # Sidebar navigation link with automatic active-state detection.
  # Pass the icon as a block (an inline SVG). `match:` overrides the path
  # prefix used to decide the active state (defaults to the link path).
  def sidebar_link(path, label, match: nil, &block)
    match = (match || path).to_s
    active = request.path == path || (match.length > 1 && request.path.start_with?(match))
    classes = class_names(
      "relative group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors duration-150",
      "bg-white/10 text-white before:absolute before:left-0 before:top-1/2 before:h-5 before:w-1 before:-translate-y-1/2 before:rounded-r-full before:bg-orange" => active,
      "text-white/60 hover:bg-white/[0.06] hover:text-white" => !active
    )
    content_tag :li, class: "list-none" do
      link_to path, class: classes do
        safe_join([ capture(&block), content_tag(:span, label, class: "truncate") ])
      end
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

  def lab_flag_badge(flag)
    {
      "normal" => "badge-success",
      "low" => "badge-warning",
      "high" => "badge-warning",
      "critical" => "badge-error"
    }.fetch(flag.to_s, "badge-ghost")
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
