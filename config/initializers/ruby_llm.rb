# Unified LLM configuration (Gemini + OpenAI/ChatGPT + OpenRouter) via ruby_llm.
# Keys are read from the environment under several accepted names so it works
# whether you use the project's names or the canonical ones. The app boots fine
# without any key — the AI services fall back to deterministic logic.
pick = ->(*names) { names.filter_map { |n| ENV[n].presence }.first }

RubyLLM.configure do |config|
  config.gemini_api_key     = pick.call("Google_GEMINI_API_KEY", "GEMINI_API_KEY", "GOOGLE_GEMINI_API_KEY")
  config.openai_api_key     = pick.call("OPENAI_API_KEY", "OPEN_AI_API_KEY", "OPENAI_KEY")
  config.openrouter_api_key = pick.call("Route_LLM_API_KEY", "OPENROUTER_API_KEY", "ROUTE_LLM_API_KEY")

  config.request_timeout = Integer(ENV.fetch("AI_REQUEST_TIMEOUT", 60))
  config.default_model   = ENV.fetch("AI_DEFAULT_MODEL", "gemini-2.0-flash")
end
