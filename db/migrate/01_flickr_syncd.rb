Sequel.migration do
  change do
    create_table(:photos) do
      String :id, :size=>255, :null=>false
      Integer :user_id, :null=>false
      String :secret, :size=>50
      String :server, :size=>50
      Integer :farm
      String :title, :size=>255
      String :ispublic
      String :isfriend
      String :isfamily
      String :set_id, :size=>50
    end
    
    create_table(:sets) do
      String :id, :size=>50, :null=>false
      String :name, :size=>255, :null=>false
    end
    
    create_table(:users) do
      Integer :id, :null=>false
      String :flickr_user_id, :size=>255
      String :flickr_user_name, :size=>255
    end
  end
end
