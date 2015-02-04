class CreateImages < ActiveRecord::Migration
  def self.up
    
    create_table :images do |t|
      t.string        :title,             :limit => 192
      t.string        :subject_code,      :limit => 708
      t.text          :subject
      t.string        :instructions,      :limit => 768
      t.string        :creator,           :limit => 96
      t.string        :city,              :limit => 96
      t.string        :location,          :limit => 96
      t.string        :state,             :limit => 96
      t.string        :country,           :limit => 192
      t.string        :headline,          :limit => 768
      t.string        :credit,            :limit => 96
      t.string        :source,            :limit => 96
      t.text          :description
      t.string        :reportage,         :limit => 96
      t.string        :normalized_credit, :limit => 192
      t.integer       :max_avail_width
      t.integer       :max_avail_height
      t.string        :original_filename, :limit => 255
      t.text          :provider_comment
      t.string        :ns_prefixes,       :limit => 255
      t.integer       :alt_lang_title_id, :alt_lang_copyright_id, :alt_lang_description_id, :xmp_image_id
      t.datetime      :date_created, :reception_date
      t.string        :thumb_location,   :limit => 255
      t.string        :medium_location,  :limit => 255
      t.string        :hires_location,   :limit => 1000
      t.string        :restrictions,     :limit => 512
      t.timestamp     :reception_date
      t.references    :provider
      t.timestamps
    end
    
    add_index  :images, :alt_lang_title_id
    add_index  :images, :alt_lang_copyright_id
    add_index  :images, :alt_lang_description_id
    add_index  :images, :xmp_image_id
    add_index  :images, :reportage
    add_index  :images, :provider_id 
    add_index  :images, :reception_date 
    
  end

  def self.down
    remove_index  :images, :reportage
    remove_index  :images, :alt_lang_title_id
    remove_index  :images, :alt_lang_copyright_id
    remove_index  :images, :alt_lang_description_id
    remove_index  :images, :xmp_image_id
    remove_index  :images, :provider_id
    drop_table :images
  end
end