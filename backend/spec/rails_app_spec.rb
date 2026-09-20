require 'rails_helper'

RSpec.describe "Rails Application Foundation" do
  it "boots the application in test environment" do
    expect(Rails.env.test?).to be true
  end

  it "connects to the SQLite database successfully" do
    expect(ActiveRecord::Base.connection.adapter_name).to eq("SQLite")
  end
end
