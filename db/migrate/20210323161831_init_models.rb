class InitModels < ActiveRecord::Migration[6.0]
  def change
    create_table :doctors do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :patients do |t|
      t.references :doctor
      t.string :name, null: false
      t.timestamps
    end

    create_table :appointments do |t|
      t.references :doctor
      t.references :patient

      t.timestamps
    end
  end
end
