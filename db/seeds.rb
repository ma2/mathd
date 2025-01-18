# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "csv"

csv_data = []
CSV.foreach('db/mondai2.csv', headers: true) do |row|
  csv_data <<
    { date: row['date'], expression: row['expression'], value: row['value'], qid: row['qid'] }
end
Question.insert_all(csv_data)
