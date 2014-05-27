# -*- coding: utf-8 -*-
require 'spec_helper'

describe "memos" do
  let(:text_of_link_to_index) { "index" }
  let(:text_of_link_to_new) { "create new memo" }
  let(:text_of_link_to_delete) { "delete" }
  let(:text_of_button_to_create) { "create" }

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  example "index" do
    3.times { FactoryGirl.create :memo }
    visit memos_path
    expect(page).to have_link text_of_link_to_new
    expect(page).to have_content "#{Memo.count} memo"
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  example "new" do
    visit new_memo_path
    expect(page).to have_content /text/i
    expect(page).to have_button text_of_button_to_create
    expect(page).to have_link text_of_link_to_index
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  example "show" do
    sample_text = "hello world"
    memo = FactoryGirl.create(:memo, text: sample_text)
    expect(Memo.count).to be > 0
    expect { Memo.find memo.id }.not_to raise_error
    visit "/memos/#{memo.id}"
    expect(page).to have_content memo.text
    expect(page).to have_link text_of_link_to_index
    expect(page).to have_link text_of_link_to_delete
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  example "index -> new -> create -> result(OK)" do
    visit memos_path
    click_link text_of_link_to_new
    sample_text = "hello world"
    fill_in "Text", with: sample_text
    click_button text_of_button_to_create
    expect(page).to have_content /created successfully/i
    expect(page).to have_content sample_text
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  example "index -> new -> create -> result(NG)" do
    visit memos_path
    click_link text_of_link_to_new
    longest_text = "a" * (Memo::MAX_LENGTH + 1)
    target_field = "Text"
    fill_in target_field, with: longest_text
    click_button text_of_button_to_create
    expect(page).to have_content /error/i
    expect(find_field(target_field).value).to eq longest_text
    expect(page).to have_button text_of_button_to_create
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  # example "show -> destroy(OK)", js: true do
  example "show -> destroy(OK)" do
    sample_text = "hello world"
    memo = FactoryGirl.create :memo, text: sample_text
    visit "/memos/#{memo.id}"
    # page.save_screenshot "gitignore/screenshots/memos_show_destroy_1.png"
    click_link text_of_link_to_delete
    # page.save_screenshot "gitignore/screenshots/memos_show_destroy_2.png"
    expect(page).to have_content /deleted successfully/i
    expect { FactoryGirl.find memo.id }.to raise_error
    # page.save_screenshot "gitignore/screenshots/memos_show_destroy_3.png"
  end

end
