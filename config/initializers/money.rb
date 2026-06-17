MoneyRails.configure do |config|
  # Configurable so the app isn't tied to one country. Set DEFAULT_CURRENCY
  # (e.g. usd, gbp, eur, ngn) in the environment; defaults to USD.
  config.default_currency = ENV.fetch("DEFAULT_CURRENCY", "usd").downcase.to_sym
  config.locale_backend = :i18n
  config.rounding_mode = BigDecimal::ROUND_HALF_UP
end
