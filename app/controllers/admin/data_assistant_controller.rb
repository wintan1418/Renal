module Admin
  class DataAssistantController < Admin::BaseController
    def index; end

    # POST /admin/data_assistant/ask (JSON)
    def ask
      result = Ai::DataAnalyst.call(params[:question])
      render json: { answer: result.content, source: result.ai? ? "AI · #{result.source}" : "snapshot" }
    end
  end
end
