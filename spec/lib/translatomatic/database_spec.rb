RSpec.describe Translatomatic::Database do
  it "should create a database" do
    db_file = create_tempfile("db.sqlite3")
    db_file.delete

    db_config = {
      "adapter" => "sqlite3", "encoding" => "utf-8", "database" => db_file.to_s
    }
    db = Translatomatic::Database.new(database_config: db_config)
    expect(db).to be
    db.create
    expect(db_file.exist?).to be_truthy
  end
end
