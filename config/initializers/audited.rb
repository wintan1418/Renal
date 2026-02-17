# Allow Date and Time types in YAML serialization for audit logs
Rails.application.config.active_record.yaml_column_permitted_classes = [
  Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone,
  BigDecimal, ActiveSupport::HashWithIndifferentAccess
]
