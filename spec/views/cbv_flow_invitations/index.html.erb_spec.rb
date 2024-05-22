require 'rails_helper'

RSpec.describe "cbv_flow_invitations/index", type: :view do
  before(:each) do
    assign(:cbv_flow_invitations, [
      CbvFlowInvitation.create!(),
      CbvFlowInvitation.create!()
    ])
  end

  it "renders a list of cbv_flow_invitations" do
    render
  end
end
