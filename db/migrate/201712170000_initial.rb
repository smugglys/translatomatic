# @!visibility private
class Initial < ActiveRecord::Migration[4.2] # :nodoc:
  def change
    create_table :locales do |t|
      t.string :language, null: false  # e.g. "en"   ISO 639-1
      t.string :script                 # e.g. "Hans" ISO 15924
      t.string :region                 # e.g. "US"   ISO 3166-1 alpha-2
      t.timestamps
    end

    add_index :locales, [:language, :script, :region], unique: true

    create_table :texts do |t|
      t.belongs_to :locale, index: true, null: false
      t.belongs_to :from_text, index: true, foreign_key: {
        to_table: :texts, on_delete: :cascade
      }
      t.text       :value, null: false
      t.boolean    :shared, null: false, default: false, index: true
      t.string     :translator
      t.timestamps
    end

  end
end
