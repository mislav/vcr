require 'spec_helper'

describe "Typhoeus hook", :with_monkey_patches => :typhoeus do
  after(:each) do
    ::Typhoeus::Hydra.clear_stubs
  end

  def disable_real_connections
    ::Typhoeus::Hydra.allow_net_connect = false
    ::Typhoeus::Hydra::NetConnectNotAllowedError
  end

  def enable_real_connections
    ::Typhoeus::Hydra.allow_net_connect = true
  end

  def directly_stub_request(method, url, response_body)
    response = ::Typhoeus::Response.new(:code => 200, :body => response_body)
    ::Typhoeus::Hydra.stub(method, url).and_return(response)
  end

  it_behaves_like 'a hook into an HTTP library', :typhoeus, 'typhoeus'

  describe "VCR.configuration.after_library_hooks_loaded hook" do
    it 'disables the webmock typhoeus adapter so it does not conflict with our typhoeus hook' do
      ::WebMock::HttpLibAdapters::TyphoeusAdapter.should_receive(:disable!)
      $typhoeus_after_loaded_hook.conditionally_invoke
    end
  end
end unless RUBY_PLATFORM == 'java'

