module MarketingHelper
  # Single-path line icons (ported from the redesign prototype).
  MK_ICONS = {
    heart:   "M12 21s-7-4.6-9.5-9C1 8.5 3 5 6.5 5 8.7 5 11 7 12 8.5 13 7 15.3 5 17.5 5 21 5 23 8.5 21.5 12 19 16.4 12 21 12 21z",
    droplet: "M12 3c3 4 6 7 6 10.5A6 6 0 0 1 6 13.5C6 10 9 7 12 3z",
    flask:   "M9 3h6M10 3v6l-5 9a2 2 0 0 0 2 3h10a2 2 0 0 0 2-3l-5-9V3",
    doc:     "M7 3h7l5 5v13a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM14 3v6h6",
    shield:  "M12 3l8 4v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V7l8-4z",
    pulse:   "M3 12h4l3 8 4-16 3 8h4",
    user:    "M20 21a8 8 0 0 0-16 0M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z",
    clip:    "M9 4h6v3H9zM7 5H5v16h14V5h-2M9 12h6M9 16h4",
    leaf:    "M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.5 19 2c1 2 2 4.5 2 7a8 8 0 0 1-8 8M3 21c0-5 4-9 9-10",
    pin:     "M12 21s-7-7-7-12a7 7 0 0 1 14 0c0 5-7 12-7 12zM12 11a2 2 0 1 0 0-4 2 2 0 0 0 0 4z",
    phone:   "M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3 19.5 19.5 0 0 1-6-6 19.8 19.8 0 0 1-3-8.6A2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 1.9.7 2.8a2 2 0 0 1-.5 2.1L8.1 9.9a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.5c.9.3 1.8.6 2.8.7a2 2 0 0 1 1.7 2.1z",
    mail:    "M4 5h16a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1zM3 7l9 6 9-6",
    clock:   "M12 7v5l3 2M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z",
    check:   "M20 6L9 17l-5-5",
    arrow:   "M5 12h14M13 6l6 6-6 6",
    menu:    "M3 6h18M3 12h18M3 18h18"
  }.freeze

  # Render an inline line-icon SVG by key.
  def mk_icon(key, size: 22, stroke: "currentColor", width: 1.9)
    path = MK_ICONS[key] || MK_ICONS[:droplet]
    content_tag :svg, content_tag(:path, "", d: path),
                width: size, height: size, viewBox: "0 0 24 24", fill: "none",
                stroke: stroke, "stroke-width": width, "stroke-linecap": "round", "stroke-linejoin": "round"
  end

  # Map a Service to an icon + colour tint + category label for the cards.
  def service_visual(service)
    name = service.name.to_s.downcase
    case service.service_type.to_s
    when "dialysis"
      { icon: :droplet, tint: "mk-t-blue", cat: "Treatment" }
    when "lab_test"
      { icon: :flask, tint: "mk-t-teal", cat: "Laboratory" }
    when "procedure"
      { icon: :doc, tint: "mk-t-purple", cat: "Diagnostic" }
    else
      if name.include?("transplant")
        { icon: :heart, tint: "mk-t-coral", cat: "Surgery" }
      elsif name.include?("diet") || name.include?("nutrition")
        { icon: :leaf, tint: "mk-t-amber", cat: "Support" }
      elsif name.include?("follow")
        { icon: :clip, tint: "mk-t-green", cat: "Consultation" }
      else
        { icon: :shield, tint: "mk-t-green", cat: "Consultation" }
      end
    end
  end

  MK_BLOG_IMAGES = {
    "kidney_health"  => "marketing/blog/ckd.jpg",
    "nutrition"      => "marketing/blog/nutrition.jpg",
    "dialysis_tips"  => "marketing/blog/first-dialysis.jpg",
    "dialysis"       => "marketing/blog/first-dialysis.jpg",
    "lifestyle"      => "marketing/blog/active.jpg",
    "general_health" => "marketing/blog/active.jpg"
  }.freeze
  MK_BLOG_FALLBACKS = [ "marketing/blog/fluid.jpg", "marketing/blog/kidney-test.jpg" ].freeze

  def blog_image_for(post, index = 0)
    MK_BLOG_IMAGES[post.category.to_s] || MK_BLOG_FALLBACKS[index % MK_BLOG_FALLBACKS.size]
  end

  def blog_category_label(post)
    post.category.to_s.humanize.titleize
  end

  # Ordered stand-in doctor headshots (F/M alternating to match seed order).
  MK_DOCTOR_PHOTOS = %w[
    marketing/doctors/amara.jpg
    marketing/doctors/tunde.jpg
    marketing/doctors/ngozi.jpg
    marketing/doctors/oluwaseun.jpg
    marketing/doctors/ibrahim.jpg
    marketing/doctors/funke.jpg
  ].freeze

  def doctor_photo(index)
    MK_DOCTOR_PHOTOS[index % MK_DOCTOR_PHOTOS.size]
  end

  # Stable photo for a doctor on detail pages — keeps the same headshot the
  # index page used by mapping on the doctor's position in the ordered list.
  def doctor_photo_for(doctor)
    @mk_doctor_order ||= User.doctors.active.order(:id).pluck(:id)
    idx = @mk_doctor_order.index(doctor.id) || (doctor.id % MK_DOCTOR_PHOTOS.size)
    doctor_photo(idx)
  end

  def doctor_specialty(doctor)
    doctor.staff_profile&.specialization.presence || "Nephrology"
  end

  def blog_read_time(post)
    words = post.body.to_s.split.size
    minutes = [ (words / 200.0).ceil, 3 ].max
    "#{minutes} min read"
  end

  def doctor_rating(doctor)
    # Stable pseudo-rating from id so it doesn't jump around between renders.
    (47 + (doctor.id % 4)) / 10.0
  end
end
