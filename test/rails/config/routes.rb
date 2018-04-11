Rails.application.routes.draw do
  %w[normal no_layout variables content_for].each do |action|
    get action, controller: 'application', action: action
  end
end
