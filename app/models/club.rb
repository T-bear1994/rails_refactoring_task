class Club < ApplicationRecord
  has_one_attached :logo

  has_many :home_matches, class_name: "Match", foreign_key: "home_team_id"
  has_many :away_matches, class_name: "Match", foreign_key: "away_team_id"
  has_many :players
  belongs_to :league

  def matches
    Match.where("home_team_id = ? OR away_team_id = ?", self.id, self.id)
  end

  def matches_on(year = nil)
    return nil unless year

    matches.where(kicked_off_at: Date.new(year, 1, 1).in_time_zone.all_year)
  end

  def won?(match)
    match.winner == self
  end

  def lost?(match)
    match.loser == self
  end

  def draw?(match)
    match.draw?
  end

  def win_on(year)
    count_result_on(year, "win")
  end

  def lost_on(year)
    count_result_on(year, "lost")
  end

  def draw_on(year)
    count_result_on(year, "draw")
  end

  def homebase
    "#{hometown}, #{country}"
  end

  def average_age
    (self.players.sum(&:age) / self.players.length).to_f
  end

  private

  def count_result_on(year, result)
    year = Date.new(year, 1, 1)
    win_count = 0
    lost_count = 0
    draw_count = 0

    matches.where(kicked_off_at: year.all_year).each do |match|
      win_count += 1 if won?(match)
      lost_count += 1 if lost?(match)
      draw_count += 1 if draw?(match)
    end

    if result == "win"
      count = win_count
    elsif result == "lost"
      count = lost_count
    else
      count = draw_count
    end
  end
  count
end
