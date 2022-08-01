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

  def count_result_on(year, kind)
    year = Date.new(year, 1, 1)
    matches_on_specified_year = matches.where(kicked_off_at: year.all_year)

    count = 0

    case kind
    when "win"
      matches_on_specified_year.each { |match| count += 1 if won?(match) }
    when "lost"
      matches_on_specified_year.each { |match| count += 1 if lost?(match) }
    when "draw"
      matches_on_specified_year.each { |match| count += 1 if draw?(match) }
    end
    count
  end
end
