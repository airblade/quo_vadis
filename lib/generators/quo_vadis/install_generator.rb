module QuoVadis
  class InstallGenerator < Rails::Generators::Base
    source_root Pathname.new(__dir__) / '..' / '..' / '..' / 'test' / 'dummy' / 'app' / 'views' / 'quo_vadis'

    desc "Copy QuoVadis' views into your app."
    def copy_views
      directory '.', Pathname.new('app') / 'views' / 'quo_vadis'
    end
  end
end
