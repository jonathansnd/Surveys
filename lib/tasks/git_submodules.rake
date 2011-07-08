namespace :git do
	namespace :submodules do
    	desc "Initialize git submodules"
    	task :init do
      		system ("git submodule init")
      		system ("git submodule update")
    	end
	end
end