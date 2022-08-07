class League < ApplicationRecord
  WIN_POINTS = 3
  DRAW_POINTS = 1

  has_many :matches
  has_many :clubs

  def table_rows(year=Time.current.year)
    rows = clubs.map { |club| Poros::LeagueTableRow.new(club, year) }

    ranked_rows_by_points = rank_rows(rows)
    rank_rows_have_the_same_points(ranked_rows_by_points)
  end

  private

  def has_same_points_rows?(rows)
    rows.size != rows.map(&:points).uniq.size
  end

  def rank_rows(rows)
    rows_desc_sorted_by_points = rows.sort_by { |club| club.points }.reverse
    rows_desc_sorted_by_points.each { |row| row.rank = rows_desc_sorted_by_points.index(row) + 1 }
  end

  def rank_rows_have_the_same_points(rows)
    # Compare the two rows next to each other in the standings.
    # If the points are the same, the one with the most goal difference will be on top.
    # If the goal difference is the same, the one with the most wins per year will be ranked higher.
    # If they are still the same, they will be ranked in the same rate and displayed in dictionary order.
    return rows unless has_same_points_rows?(rows)

    rows.each_cons(2) do |upper_club, lower_club|
      if upper_club.goal_difference > lower_club.goal_difference
        next
      elsif upper_club.goal_difference < lower_club.goal_difference
        lower_club.rank = upper_club.rank
        upper_club.rank += 1
      elsif upper_club.goal_difference == lower_club.goal_difference
        if upper_club.win > lower_club.win
          next
        elsif upper_club.win < lower_club.win
          lower_club.rank = upper_club.rank
          upper_club.rank += 1
        elsif upper_club.win == lower_club.win
          lower_club.rank = upper_club.rank
        end
      end
    end
    rows.sort_by { |row| [row.rank, row.club.name] }
  end
end
