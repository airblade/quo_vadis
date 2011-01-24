module QuoVadis
  class Engine < ::Rails::Engine
    initializer 'quo_vadis.model' do |app|
      ActiveSupport.on_load(:active_record) do
        include ModelMixin
      end
    end

    initializer 'quo_vadis.controller' do |app|
      ActiveSupport.on_load(:action_controller) do
        include ControllerMixin
      end
    end
  end
end
