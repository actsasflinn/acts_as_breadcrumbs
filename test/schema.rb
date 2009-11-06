ActiveRecord::Schema.define(:version => 1) do
  create_table :nodes, :force => true do |t|
    t.string :name
    t.string :breadcrumbs

    # nested_set
    t.integer :parent_id
    t.integer :lft
    t.integer :rgt
  end

  create_table :locations, :force => true do |t|
    t.string :name
    t.string :location_string

    # nested_set
    t.integer :parent_id
    t.integer :lft
    t.integer :rgt
  end

  create_table :soldiers, :force => true do |t|
    t.string :name
    t.string :chain_o_command

    # nested_set
    t.integer :parent_id
    t.integer :lft
    t.integer :rgt
  end

  create_table :web_pages, :force => true do |t|
    t.string :title
    t.string :slug
    t.string :url
    t.string :breadcrumbs

    # nested_set
    t.integer :parent_id
    t.integer :lft
    t.integer :rgt
  end
end