require 'minitest/autorun'

describe 'Checking trema installed' do

  it "should exist" do
    assert File.exists?("/usr/local/bin/trema")
  end

  it "should be executable" do
    assert File.executable?("/usr/local/bin/trema")
  end

  it "should be right version" do
    assert system("/usr/local/bin/trema 2>/dev/null | grep 'trema 0.3.0' 1>/dev/null")
  end

end
