# -*- coding: utf-8 -*-
require 'spec_helper'

describe Memo do
  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  context "save" do
    it "should have text" do
      expect(Memo.new.save).to be_false
      expect(Memo.new(text: "abc").save).to be_true
      expect(Memo.new(text: "あいう").save).to be_true

    end
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "id" do
    it "should be > 0"  do
      expect(Memo.count).to be 0
      100.times {
        memo = FactoryGirl.create :memo
        expect(memo.id).to be > 0
      }
    end
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "text" do
    it "should not be filled with whites" do
      [nil, "", " ", " " * 10, "　", "\t", " \t"].each { |s|
        expect(Memo.new(text: s).save).to be_false
      }
    end

    it "may have whites" do
      ["a ", " a", " a ", "a b", "あ　い", "a\tb"].each { |s|
        expect(Memo.new(text: s).save).to be_true
      }
    end

    specify "MAX_LENGTH > 0" do
      expect(Memo::MAX_LENGTH).to be > 0
    end

    it "has max length" do
      ["a", "あ"].each { | c1 |
        just_max = c1 * Memo::MAX_LENGTH
        expect(Memo.new(text: just_max).save).to be_true
        over_max = just_max + c1
        expect(Memo.new(text: over_max).save).to be_false
      }
    end
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  # describe "truncated" do
  #   specify "0 < TRUNCATED_LENGTH < MAX_LENGTH" do
  #     expect(Memo::TRUNCATED_LENGTH).to be > 0
  #     expect(Memo::TRUNCATED_LENGTH).to be < Memo::MAX_LENGTH
  #   end

  #   specify "0 < TRUNCATED_OMISSION.length < 10" do
  #     expect(Memo::TRUNCATED_OMISSION.length).to be > 0
  #     expect(Memo::TRUNCATED_OMISSION.length).to be < 10
  #   end

  #   ["a", "あ"].each { | c1 |
  #     example do
  #       full = c1 * 5
  #       memo = FactoryGirl.create :memo, text: full
  #       expect(memo.text).to eq full
  #       expect(memo.truncated).to eq full
  #     end

  #     example do
  #       full = c1 * (Memo::TRUNCATED_LENGTH + 1)
  #       memo = FactoryGirl.create :memo, text: full
  #       expect(memo.text).to eq full
  #       expect(memo.truncated).not_to eq full
  #       expect(memo.truncated.length).to eq Memo::TRUNCATED_LENGTH
  #       n = Memo::TRUNCATED_OMISSION.length
  #       expect(memo.truncated[-n, n]).to eq Memo::TRUNCATED_OMISSION
  #     end
  #   }
  # end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "FactoryGirl" do
    example do
      memo = nil
      expect { memo = FactoryGirl.create :memo }.to change(Memo, :count).by(1)
      expect(memo).to be_valid
      expect(memo).to be_persisted
    end
  end

end
