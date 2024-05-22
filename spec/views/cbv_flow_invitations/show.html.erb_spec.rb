require 'rails_helper'

RSpec.describe "cbv_flow_invitations/show", type: :view do
  before(:each) do
    @cbv_flow_invitation = assign(:cbv_flow_invitation, CbvFlowInvitation.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
