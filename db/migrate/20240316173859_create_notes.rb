class CreateNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :notes, id: false do |t|
      t.uuid :id, primary_key: true, default: 'gen_random_uuid()'
      t.string :name, limit: 50, null: false, index: { unique: true, name: 'notes_name_index' }
      t.string :content,null: false

    end
  end
end
