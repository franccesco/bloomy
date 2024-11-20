# frozen_string_literal: true

RSpec.describe "Plugin System" do
  context "when registering a plugin" do
    it "applies a plugin and executes its method" do
      client = Bloomy::Client.new

      plugin = Module.new do
        def self.apply(client)
          client.define_singleton_method(:custom_action) { "Hello, plugin!" }
        end
      end

      Bloomy::Utilities::Plugin.register(plugin)
      Bloomy::Utilities::Plugin.apply(client)

      expect(client.custom_action).to eq("Hello, plugin!")
    end
  end
end
