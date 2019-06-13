Rails.application.routes.draw do
  get 'top'                            => "home#top"
  get 'input_cash_data'                => "home#input_cash_data"
  post 'flow'                          => "home#flow"
  get 'number_of_children'             => "home#number_of_children"
  get 'educational_expenses'           => "home#educational_expenses"
  post 'child_rearing'                 => "home#child_rearing"
  post 'add_educational_expenses_flow' => "home#add_educational_expenses_flow"

end
