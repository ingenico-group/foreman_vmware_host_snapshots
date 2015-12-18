Rails.application.routes.draw do
	constraints(:host_id => /[^\/]+/) do
		resources :hosts, :except => [:new, :edit] do
			constraints(:id => /[^\/]+/) do
				resources :vmware_snapshots,        :only => [:index]
			end
		end
	end

	namespace :api, :defaults => {:format => 'json'} do
		scope "(:apiv)", :module => :v2,
		:defaults => {:apiv => 'v2'},
		:apiv => /v1|v2/,
		:constraints => ApiConstraints.new(:version => 2, :default => true) do
			constraints(:host_id => /[^\/]+/) do
				resources :hosts, :except => [:new, :edit] do
					constraints(:id => /[^\/]+/) do
						resources :vmware_snapshots,        :except => [:new, :edit] do
							put :revert, :on => :member
							delete :destroy_all, :on => :collection
						end
					end
				end
			end
		end
	end
end
