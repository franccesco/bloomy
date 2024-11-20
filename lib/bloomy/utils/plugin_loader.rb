module Bloomy
  module Utilities
    module Plugin
      # A collection of registered plugins.
      @plugins = []

      class << self
        # Registers a plugin module.
        #
        # @param plugin_module [Module] The plugin module to register.
        # @return [void]
        def register(plugin_module)
          @plugins << plugin_module
        end

        # Applies all registered plugins to the given client.
        #
        # @param client [Object] The client to which the plugins will be applied.
        # @return [void]
        def apply(client)
          @plugins.each do |plugin|
            plugin.apply(client)
          end
        end
      end
    end
  end
end
