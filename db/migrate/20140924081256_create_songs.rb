class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|

      t.timestamps
    end
  end
end
