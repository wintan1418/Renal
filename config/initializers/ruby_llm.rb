# Unified LLM configuration (Gemini + OpenAI/ChatGPT) via the ruby_llm gem.
# Keys are read from the environment so the app boots fine without them —
# the AI services fall back to deterministic logic when no key is present.
RubyLLM.configure do |config|
  config.gemini_api_key  = ENV["GEMINI_API_KEY"].presence
  config.openai_api_key  = ENV["OPENAI_API_KEY"].presence
  config.request_timeout = Integer(ENV.fetch("AI_REQUEST_TIMEOUT", 60))

  # Primary model — Gemini by default; override per-call or via env.
  config.default_model = ENV.fetch("AI_DEFAULT_MODEL", "gemini-2.0-flash")
end
