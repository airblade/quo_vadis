# frozen_string_literal: true

module QuoVadis

  def self.table_name_prefix
    'qv_'
  end


  class Engine < ::Rails::Engine
    isolate_namespace QuoVadis
  end
end
