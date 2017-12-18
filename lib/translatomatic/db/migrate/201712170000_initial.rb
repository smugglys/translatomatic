class Initial < ActiveRecord::Migration[4.2]
  def change
    create_table :locales do |t|
      t.string :language, index: true
      t.string :country
      t.string :variant
      t.timestamps
    end

    create_table :texts do |t|
      t.belongs_to :locale, index: true
      t.belongs_to :translated_from, index: true, foreign_key: {
         to_table: :texts }
      t.text       :value
      t.string     :translator
      t.timestamps
    end
  end
end
