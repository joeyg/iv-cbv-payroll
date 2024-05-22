class CbvFlowInvitationsController < ApplicationController
  before_action :set_cbv_flow_invitation, only: %i[ show edit update destroy ]

  # GET /cbv_flow_invitations or /cbv_flow_invitations.json
  def index
    @cbv_flow_invitations = CbvFlowInvitation.all.order(created_at: :desc)
  end

  # GET /cbv_flow_invitations/1 or /cbv_flow_invitations/1.json
  def show
  end

  # GET /cbv_flow_invitations/new
  def new
    @cbv_flow_invitation = CbvFlowInvitation.new
  end

  # GET /cbv_flow_invitations/1/edit
  def edit
  end

  # POST /cbv_flow_invitations or /cbv_flow_invitations.json
  def create
    @cbv_flow_invitation = CbvFlowInvitation.new(cbv_flow_invitation_params)

    respond_to do |format|
      if @cbv_flow_invitation.save
        format.html { redirect_to cbv_flow_invitation_url(@cbv_flow_invitation), notice: "Cbv flow invitation was successfully created." }
        format.json { render :show, status: :created, location: @cbv_flow_invitation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cbv_flow_invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cbv_flow_invitations/1 or /cbv_flow_invitations/1.json
  def update
    respond_to do |format|
      if @cbv_flow_invitation.update(cbv_flow_invitation_params)
        format.html { redirect_to cbv_flow_invitation_url(@cbv_flow_invitation), notice: "Cbv flow invitation was successfully updated." }
        format.json { render :show, status: :ok, location: @cbv_flow_invitation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cbv_flow_invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cbv_flow_invitations/1 or /cbv_flow_invitations/1.json
  def destroy
    @cbv_flow_invitation.destroy

    respond_to do |format|
      format.html { redirect_to cbv_flow_invitations_url, notice: "Cbv flow invitation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cbv_flow_invitation
      @cbv_flow_invitation = CbvFlowInvitation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cbv_flow_invitation_params
      params.fetch(:cbv_flow_invitation, {})
    end
end
