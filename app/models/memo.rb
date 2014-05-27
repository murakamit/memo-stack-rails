# -*- coding: utf-8 -*-
class Memo < ActiveRecord::Base
  MAX_LENGTH = 100
  WHITES_ONLY = /\A[\s　]+\Z/

  validates :text, presence: true
  validates :text, format: { without: WHITES_ONLY }
  validates :text, length: { maximum: MAX_LENGTH }

  PER_PAGE = 50
  paginates_per PER_PAGE
end
