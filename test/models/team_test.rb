require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test 'team with ineligible user is ineligible for prizes' do
    assert_equal(false, teams(:team_one).eligible_for_prizes?)
  end

  test 'team without team captain is automatically assigned to first user' do
    team = teams(:team_two)
    user = users(:user_three)
    team.users << user
    team.save
    assert_equal(user, team.team_captain)
  end

  test 'team with two high school students is a high school team' do
    teams(:team_one).users << users(:full_team_user_one)
    assert_equal('High School', teams(:team_one).division_level)
  end

  test 'team with one high school and one college student is a college team' do
    teams(:team_one).users << users(:user_three)
    assert_equal('College', teams(:team_one).division_level)
  end

  test 'team with one professional is professional level team' do
    assert_equal('Professional', teams(:team_three).division_level)
  end

  test 'team with one eligible user and one ineligible is ineligible for prizes' do
    teams(:team_one).users << users(:user_two)
    assert_equal(false, teams(:team_one).eligible_for_prizes?)
  end

  test 'team with two eligible users is eligible for prizes' do
    teams(:team_one).users << users(:user_two)
    users(:user_one).compete_for_prizes = true
    assert_equal(false, teams(:team_one).eligible_for_prizes?)
  end

  test 'team with profanity will not save' do
    @team = Team.new(team_name: 'hell', affiliation: 'hell')
    assert_equal(false, @team.save)
  end

  test 'promote' do
    # These users are on the same team!
    team = users(:full_team_user_one).team
    team.promote(users(:full_team_user_five))
    assert_equal team.team_captain, users(:full_team_user_five)
  end

  test 'promote a user that is not on the same team' do
    # These users are not on the same team!
    team = users(:user_one).team
    team.promote(users(:full_team_user_five))
    assert_not_equal team.team_captain, users(:full_team_user_five)
  end
end
