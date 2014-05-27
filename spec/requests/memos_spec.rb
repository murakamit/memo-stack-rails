require 'spec_helper'

describe "Memos" do

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  ["/memos", "/memos/index", "/memos/new"].each { | url |
    describe "'GET #{url}' should not change num of records" do
      example do
        expect { get url }.not_to change(Memo, :count)
      end
    end
  }

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "memos#index" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get memos_path
      expect(response).to be_success
      expect(response).to render_template :index
    end

    context "no recored" do
      it "returns @memos as empty" do
        expect(Memo.count).to eq 0
        get memos_path
        memos = assigns :memos
        expect(memos).to be_empty
      end
    end

    context "some records" do
      it "returns @memos" do
        (Memo::PER_PAGE * 2).times { FactoryGirl.create :memo }
        x = FactoryGirl.create :memo
        get memos_path
        memos = assigns :memos
        expect(memos.length).to eq Memo::PER_PAGE
        expect(memos.first).to eq x
      end
    end
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "memos#new" do
    example do
      get new_memo_path
      expect(response).to be_success
      expect(response).to render_template :new
      expect(assigns :memo).to be_an Memo
    end
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "memos#create" do
    context "without params" do
      it "redirects to #new" do
        expect { post memos_path }.not_to change(Memo, :count)
        expect(response).to redirect_to action: :new
        follow_redirect!
        expect(response).to be_success
        expect(response).to render_template :new
        memo = assigns :memo
        expect(memo.errors).to be_empty unless memo.nil?
      end
    end

    context "valid params" do
      it "redirects to #index" do
        params = { memo: FactoryGirl.attributes_for(:memo) }
        expect { post memos_path, params }.to change(Memo, :count).by(1)
        expect(response).to redirect_to action: :index
      end
    end

    context "invalid params" do
      context "flatten params" do
        it "redirects to #new" do
          params = { text: "abc" }
          expect { post memos_path, params }.not_to change(Memo, :count)
          expect(response).to redirect_to action: :new
          follow_redirect!
          expect(response).to be_success
          expect(response).to render_template :new
          memo = assigns :memo
          expect(memo.errors).to be_empty unless memo.nil?
        end
      end

      ["", "a" * (Memo::MAX_LENGTH + 1)].each { | text |
        context "invalid text '#{text}'" do
          it "returns template#new with 400(Bad Request) and includes errors" do
            h = FactoryGirl.attributes_for(:memo, text: text)
            params = { memo: h }
            expect { post memos_path, params }.not_to change(Memo, :count)
            expect(response.status).to eq 400
            expect(response).to render_template :new
            memo = assigns :memo
            expect(memo.errors).not_to be_empty
            expect(memo.text).to eq text
          end
        end
      }
    end
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "memos#show" do
    context "valid id" do
      example do
        memo = FactoryGirl.create :memo
        get "/memos/#{memo.id}"
        expect(response).to be_success
        expect(response).to render_template :show
        expect(assigns :memo).to eq memo
      end
    end

    context "invalid id" do
      it "returns 400(Bad Request)" do
        memo = FactoryGirl.create :memo
        invalid_id = memo.id + 1
        expect { Memo.find invalid_id }.to raise_error
        get "/memos/#{invalid_id}"
        expect(response.status).to eq 400
      end
    end
  end

  # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  describe "memos#destroy" do
    context "valid params" do
      example do
        memo = FactoryGirl.create :memo
        expect { delete "/memos/#{memo.id}" }.to change(Memo, :count).by(-1)
        expect(response).to redirect_to action: :index
      end
    end

    context "invalid params" do
      it "returns 400(Bad Request)" do
        memo = FactoryGirl.create :memo
        invalid_id = memo.id + 1
        expect { Memo.find invalid_id }.to raise_error
        expect { delete "/memos/#{invalid_id}" }.not_to change(Memo, :count)
        expect(response.status).to eq 400
      end
    end
  end

end
