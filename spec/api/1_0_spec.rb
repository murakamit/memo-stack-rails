# -*- coding: utf-8 -*-

require 'spec_helper'

describe API_1_0 do
  shared_examples_for "Content-Type include X" do
    example do
      urls.each { | url |
        get url
        expect(response).to be_success
        values.each { | val |
          expect(response.header["Content-Type"]).to be_include val
        }
      }
    end
  end

  def post_only(url)
    post url, nil, { CONTENT_TYPE: "application/json" }
  end

  def post_as_json(url, params)
    post url, params.to_json, { CONTENT_TYPE: "application/json" }
  end

  shared_examples_for "post and error" do
    example do
      expect { post_as_json url, params }.not_to change(Memo, :count)
      expect(response).not_to be_success
      expect(JSON.parse response.body).to be_key "error"
    end
  end

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
  describe "Content-Type" do
    it_behaves_like "Content-Type include X" do
      let(:urls) { %w(/1.0/hello /1.0/memos) }
      let(:values) { %w(application/json charset=utf-8) }
    end
  end

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
  describe "GET /hello" do
    example do 
      v = "1.0"
      get "/#{v}/hello"
      expect(response).to be_success
      h = JSON.parse response.body
      expect(h).to be_a Hash
      expect(h["version"]).to eq v
      expect(h["versions"]).to be_include v
    end
  end # "GET /hello"

  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
  describe "/memos" do
    let(:api_root) { "/1.0/memos" }

    # == == == == == == == == == == == == == == == == == == == ==
    describe "POST /memos" do
      context "valid params" do
        it "returns created object as hash" do
          params = { text: "abcde" }
          expect { post_as_json api_root, params }.to change(Memo, :count).by(1)
          expect(response).to be_success
          h = JSON.parse response.body
          expect(h).not_to be_key "error"
          expect(h).to be_key "id"
          expect(h["text"]).to eq params[:text]
        end
      end

      context "longest text" do
        it_behaves_like "post and error" do
          let(:url) { api_root }
          let(:params) { {text: "a" * (Memo::MAX_LENGTH + 1) } }
        end
      end
    end

    # == == == == == == == == == == == == == == == == == == == ==
    context "no records" do
      describe "GET /memos" do
        it "returns empty array" do
          expect(Memo.count).to eq 0
          get api_root
          expect(response).to be_success
          h = JSON.parse response.body
          expect(h).to be_a Hash
          expect(h).not_to be_empty
          number = h["number"]
          expect(number).not_to be_nil
          expect(number["total"]).to eq 0
          expect(number["per_page"]).to eq Memo::PER_PAGE
          expect(h["request_page"]).to eq 0
          expect(h["data"]).to eq []
        end
      end

      describe "GET /memos/:id" do
        example do
          expect(Memo.count).to eq 0
          get "#{api_root}/1"
          expect(response).not_to be_success
          expect(JSON.parse response.body).to be_key "error"
        end
      end

      describe "POST /memos/destroy/:id" do
        example do
          expect(Memo.count).to eq 0
          post_only "#{api_root}/destroy/1"
          expect(response).not_to be_success
          expect(JSON.parse response.body).to be_key "error"
        end
      end

      describe "GET /memos/number" do
        it "returns hash" do
          expect(Memo.count).to eq 0
          url = api_root + "/number"
          get url
          expect(response).to be_success
          h = JSON.parse response.body
          expect(h).not_to be_key "error"
          expect(h["total"]).to eq 0
          expect(h["per_page"]).to eq Memo::PER_PAGE
        end
      end
    end # "no records"

    # == == == == == == == == == == == == == == == == == == == ==
    context "some records" do
      before {
        n = Memo::PER_PAGE
        n.times { FactoryGirl.create :memo }
        @middle = FactoryGirl.create :memo
        n.times { FactoryGirl.create :memo }
        @last = FactoryGirl.create :memo
      }

      # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
      describe "GET /memos" do
        it "returns Hash" do
          get api_root
          expect(response).to be_success
          h = JSON.parse response.body
          expect(h).to be_a Hash
          expect(h).not_to be_empty
          number = h["number"]
          expect(number).not_to be_nil
          expect(number["total"]).to eq Memo.count
          expect(number["per_page"]).to eq Memo::PER_PAGE
          expect(h["request_page"]).to eq 0
          a = h["data"]
          expect(a).to be_a Array
          expect(a.length).to be <= Memo::PER_PAGE
          expect(a.first["id"]).to be > 0
        end

        example "last-updated first-out" do
          get api_root
          h = JSON.parse(response.body)["data"].first
          expect(h["id"]).to eq @last.id
          @middle.update text: "abcde"
          get api_root
          h = JSON.parse(response.body)["data"].first
          expect(h["id"]).to eq @middle.id
        end

        it "limits page size" do
          get api_root
          a = JSON.parse(response.body)["data"]
          expect(a.length).to be < Memo.count
        end
      end # "GET /memos"

      # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
      describe "GET /memos/?page=x" do
        specify do
          expect(Memo.count).to be > Memo::PER_PAGE
        end

        describe "response success anytime and returns request_page" do
          before do
            n = Memo.count
            q = n / Memo::PER_PAGE
            r = n % Memo::PER_PAGE
            @page_max = q + (r > 1 ? 1 : 0)
          end

          shared_examples_for '?page=x -> response["request_page"] == y' do
            example do
              u = defined?(url) ? url : "#{api_root}/?page=#{x}"
              get u
              expect(response).to be_success
              h = JSON.parse(response.body)
              expect(h).not_to be_nil
              expect(h["request_page"]).to eq y
            end
          end

          describe "(default) -> 0" do
            it_behaves_like '?page=x -> response["request_page"] == y' do
              let(:url) { api_root }
              let(:y) { 0 }
            end
          end

          describe "0 -> 0" do
            it_behaves_like '?page=x -> response["request_page"] == y' do
              let(:x) { 0 }
              let(:y) { 0 }
            end
          end

          describe "1 -> 1" do
            it_behaves_like '?page=x -> response["request_page"] == y' do
              let(:x) { 1 }
              let(:y) { 1 }
            end
          end

          describe "@page_max -> @page_max" do
            it_behaves_like '?page=x -> response["request_page"] == y' do
              let(:x) { @page_max }
              let(:y) { @page_max }
            end
          end

          describe "(@page_max + 1) -> (@page_max + 1)" do
            it_behaves_like '?page=x -> response["request_page"] == y' do
              let(:x) { @page_max + 1 }
              let(:y) { @page_max + 1 }
            end
          end
        end
      end # "GET /memos/page/:page"

      # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
      describe "GET /memos/:id" do
        context "valid id" do
          it "returns target object as hash" do
            get "#{api_root}/#{@middle.id}"
            expect(response).to be_success
            expect(JSON.parse response.body).not_to be_key "error"
            expect(response.body).to eq @middle.to_json
          end
        end

        context "invalid id" do
          example do
            invalid_id = @last.id + 1
            expect { Memo.find invalid_id }.to raise_error
            get "#{api_root}/#{invalid_id}"
            expect(response).not_to be_success
            expect(JSON.parse response.body).to be_key "error"
          end

          example do
            expect { get "#{api_root}/abc" }.to raise_error ActionController::RoutingError
          end
        end
      end # "GET /memos/:id"

      # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
      describe "POST /memos/destroy/:id" do
        context "valid id" do
          example do
            expect { Memo.find @middle.id }.not_to raise_error
            url = "#{api_root}/destroy/#{@middle.id}"
            expect { post_only url }.to change(Memo, :count).by(-1)
            expect(response).to be_success
            h = JSON.parse response.body
            expect(h["destroyed"]).to be_true
            expect(h["id"]).to eq @middle.id
          end

          context "invalid id" do
            example do
              invalid_id = @last.id + 1
              expect { Memo.find invalid_id }.to raise_error
              url = "#{api_root}/destroy/#{invalid_id}"
              expect { post_only url }.not_to change(Memo, :count)
              expect(response).not_to be_success
              h = JSON.parse response.body
              expect(h).to be_key "error"
              expect(h["destroyed"]).to be_false
              expect(h["id"]).to eq invalid_id
            end
          end
        end
      end # "POST /memos/destroy/:id"

      # -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
      describe "GET /memos/number" do
        it "returns hash" do
          expect(Memo.count).to be > 0
          url = api_root + "/number"
          get url
          expect(response).to be_success
          h = JSON.parse response.body
          expect(h).not_to be_key "error"
          expect(h["total"]).to eq Memo.count
          expect(h["per_page"]).to eq Memo::PER_PAGE
        end
      end # "GET /memos/number"

    end # "some records"
  end # "/memos"

end
