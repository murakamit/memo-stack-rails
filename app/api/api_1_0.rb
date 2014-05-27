# -*- coding: utf-8 -*-

class API_1_0 < Grape::API
  version "1.0", using: :path
  # prefix "api"
  format :json
  content_type :json, "application/json; charset=utf-8;"
  default_format :json
  rescue_from :all

  helpers do
    def generate_number_response
      { total: Memo.count, per_page: Memo::PER_PAGE }
    end
  end

  get :hello do
    { version: version, versions: [version] }
  end

  resource :memos do
    get do
      ActiveRecord::Base.transaction do
        number = generate_number_response
        page = params[:page].to_i
        h = { number: number, request_page: page, data: [] }
        if number[:total] > 0
          columns = [:id, :text, :updated_at]
          h[:data] = Memo.select(columns).order("updated_at DESC").page page
        end
        h
      end
    end

    get :number do
      generate_number_response
    end

    get ":id", requirements: { id: /[01-9]+/ } do
      Memo.find params[:id]
    end

    params do
      requires :text, type: String
    end
    post do
      Memo.create! text: params[:text]
    end

    post "destroy/:id", requirements: { id: /[01-9]+/ } do
      id = params[:id].to_i
      n = Memo.delete id
      if n > 0
        { id: id, destroyed: true }
      else
        error!({ id: id, destroyed: false, error: "fail to destroy ##{id}" })
      end
    end
  end

end
