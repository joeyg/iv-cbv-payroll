class Cbv::AddJobsController < Cbv::BaseController
  def show
  end

  def create
    additional_jobs = params[:additional_jobs]
    if additional_jobs == "true"
      redirect_to cbv_flow_employer_search_path
    elsif additional_jobs == "false"
      redirect_to cbv_flow_summary_path
    else
      redirect_to cbv_flow_add_job_path, notice: t(".notice")
    end
  end
end
