class AddGrantContractTemplateName < ActiveRecord::Migration[4.2]
  def change
    add_column :grants, :contract_template, :string
  end
end
