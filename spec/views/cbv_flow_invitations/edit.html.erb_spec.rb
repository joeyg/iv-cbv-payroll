require 'rails_helper'

RSpec.describe "cbv_flow_invitations/edit", type: :view do
  before(:each) do
    @cbv_flow_invitation = assign(:cbv_flow_invitation, CbvFlowInvitation.create!())
  end

  it "renders the edit cbv_flow_invitation form" do
    render

    assert_select "form[action=?][method=?]", cbv_flow_invitation_path(@cbv_flow_invitation), "post" do
    end
  end
end
