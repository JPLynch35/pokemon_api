# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180929012601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_states", force: :cascade do |t|
    t.string "data", default: "{}"
    t.bigint "game_id"
    t.index ["game_id"], name: "index_game_states_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "player_one_uuid"
    t.string "player_two_uuid"
    t.bigint "roster_one_base_id"
    t.bigint "roster_two_base_id"
    t.string "token"
    t.integer "current_state", default: 0
    t.index ["roster_one_base_id"], name: "index_games_on_roster_one_base_id"
    t.index ["roster_two_base_id"], name: "index_games_on_roster_two_base_id"
    t.index ["token"], name: "index_games_on_token", unique: true
  end

  create_table "pokemon_bases", force: :cascade do |t|
    t.string "species_name"
    t.integer "level"
    t.integer "hp_iv"
    t.integer "hp_ev"
    t.integer "attack_iv"
    t.integer "attack_ev"
    t.integer "defense_iv"
    t.integer "defense_ev"
    t.integer "special_iv"
    t.integer "special_ev"
    t.integer "speed_iv"
    t.integer "speed_ev"
    t.string "move_one"
    t.string "move_two"
    t.string "move_three"
    t.string "move_four"
    t.bigint "roster_base_id"
    t.index ["roster_base_id"], name: "index_pokemon_bases_on_roster_base_id"
  end

  create_table "roster_bases", force: :cascade do |t|
    t.string "name"
  end

  create_table "turn_infos", force: :cascade do |t|
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "game_states", "games"
  add_foreign_key "games", "roster_bases", column: "roster_one_base_id"
  add_foreign_key "games", "roster_bases", column: "roster_two_base_id"
  add_foreign_key "pokemon_bases", "roster_bases", column: "roster_base_id"
end
