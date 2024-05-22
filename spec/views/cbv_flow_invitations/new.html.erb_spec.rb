require 'rails_helper'

RSpec.describe "cbv_flow_invitations/new", type: :view do
  before(:each) do
    assign(:cbv_flow_invitation, CbvFlowInvitation.new())
  end

  it "renders new cbv_flow_invitation form" do
    render

    assert_select "form[action=?][method=?]", cbv_flow_invitations_path, "post" do
    end
  end
end
