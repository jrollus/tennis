# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_10_100612) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "category"
    t.integer "age_min"
    t.integer "age_max"
    t.string "gender"
    t.string "age"
    t.string "c_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "category_rankings", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "ranking_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_category_rankings_on_category_id"
    t.index ["ranking_id"], name: "index_category_rankings_on_ranking_id"
  end

  create_table "category_rounds", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "round_id", null: false
    t.integer "points"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_category_rounds_on_category_id"
    t.index ["round_id"], name: "index_category_rounds_on_round_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "website"
    t.string "email"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "court_types", force: :cascade do |t|
    t.string "court_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "courts", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.bigint "court_type_id", null: false
    t.boolean "indoor"
    t.boolean "light"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["club_id"], name: "index_courts_on_club_id"
    t.index ["court_type_id"], name: "index_courts_on_court_type_id"
  end

  create_table "game_players", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "game_id", null: false
    t.bigint "ranking_id"
    t.boolean "victory"
    t.boolean "validated"
    t.integer "match_points_saved", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_game_players_on_game_id"
    t.index ["player_id"], name: "index_game_players_on_player_id"
    t.index ["ranking_id"], name: "index_game_players_on_ranking_id"
  end

  create_table "game_sets", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.integer "set_number"
    t.integer "games_1"
    t.integer "games_2"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_game_sets_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "tournament_id", null: false
    t.bigint "player_id"
    t.bigint "court_type_id"
    t.bigint "round_id", null: false
    t.date "date"
    t.string "round"
    t.string "status"
    t.boolean "indoor"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["court_type_id"], name: "index_games_on_court_type_id"
    t.index ["player_id"], name: "index_games_on_player_id"
    t.index ["round_id"], name: "index_games_on_round_id"
    t.index ["tournament_id"], name: "index_games_on_tournament_id"
  end

  create_table "nbr_participant_rules", force: :cascade do |t|
    t.integer "lower_bound"
    t.integer "upper_bound"
    t.float "weight"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "players", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "club_id", null: false
    t.bigint "player_creator_id"
    t.string "affiliation_number"
    t.string "gender"
    t.string "first_name"
    t.string "last_name"
    t.string "dominant_hand"
    t.date "birthdate"
    t.boolean "validated"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["club_id"], name: "index_players_on_club_id"
    t.index ["player_creator_id"], name: "index_players_on_player_creator_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "ranking_histories", force: :cascade do |t|
    t.bigint "ranking_id", null: false
    t.bigint "player_id", null: false
    t.integer "year"
    t.integer "year_number"
    t.date "start_date"
    t.date "end_date"
    t.integer "points", default: 0
    t.string "national_ranking"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_ranking_histories_on_player_id"
    t.index ["ranking_id"], name: "index_ranking_histories_on_ranking_id"
  end

  create_table "rankings", force: :cascade do |t|
    t.string "name"
    t.integer "points"
    t.string "r_type"
    t.integer "age_min"
    t.integer "age_max"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tie_breaks", force: :cascade do |t|
    t.bigint "game_set_id", null: false
    t.integer "points_1"
    t.integer "points_2"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_set_id"], name: "index_tie_breaks_on_game_set_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.bigint "club_id", null: false
    t.bigint "category_id", null: false
    t.bigint "player_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "nbr_participants"
    t.boolean "validated"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_tournaments_on_category_id"
    t.index ["club_id"], name: "index_tournaments_on_club_id"
    t.index ["player_id"], name: "index_tournaments_on_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "category_rankings", "categories"
  add_foreign_key "category_rankings", "rankings"
  add_foreign_key "category_rounds", "categories"
  add_foreign_key "category_rounds", "rounds"
  add_foreign_key "courts", "clubs"
  add_foreign_key "courts", "court_types"
  add_foreign_key "game_players", "games"
  add_foreign_key "game_players", "players"
  add_foreign_key "game_players", "rankings"
  add_foreign_key "game_sets", "games"
  add_foreign_key "games", "court_types"
  add_foreign_key "games", "players"
  add_foreign_key "games", "rounds"
  add_foreign_key "games", "tournaments"
  add_foreign_key "players", "clubs"
  add_foreign_key "players", "players", column: "player_creator_id"
  add_foreign_key "players", "users"
  add_foreign_key "ranking_histories", "players"
  add_foreign_key "ranking_histories", "rankings"
  add_foreign_key "tie_breaks", "game_sets"
  add_foreign_key "tournaments", "categories"
  add_foreign_key "tournaments", "clubs"
  add_foreign_key "tournaments", "players"
end
