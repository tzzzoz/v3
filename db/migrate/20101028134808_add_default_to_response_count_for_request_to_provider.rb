class AddDefaultToResponseCountForRequestToProvider < ActiveRecord::Migration
  def self.up
    change_column_default :request_to_providers, :responses_count, 0
  end

  def self.down
    change_column_default :request_to_providers, :responses_count, nil
  end
end
