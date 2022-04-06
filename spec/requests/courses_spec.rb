require 'rails_helper'
RSpec.describe "Courses", type: :request do
  describe "GET /" do
    it 'renders something login template' do
      get "/"
      expect(response).to render_template(:login)
    end
  end

  describe "POST /api_key" do
    it 'sets a cookie to be eq to access_token' do
      allow(RestClient).to receive(:post).and_return({ access_token: '12345' }.to_json)
      post '/api_key'
      expect(cookies[:teachbase_token]).to eq '12345'
    end
  end

  describe "GET /index" do
    subject { get "/index" }

    it 'redirects to login page if unauthorized' do
      allow(RestClient::Request).to receive(:execute).and_raise(RestClient::Unauthorized)

      expect(subject).to redirect_to('/login')
    end

    it 'renders index template just like we wanted to' do
      response = double('Response')
      response_body = [{ id: 1, name: 'Курс 1' }, { id: 1, name: 'Курс 2' }].to_json
      allow(response).to receive(:body).and_return(response_body)

      allow(RestClient::Request).to receive(:execute).and_return(response)

      get "/index"
      expect(subject).to render_template(:index)
    end

    it 'stores the first page courses and last_available time in cache' do
      response = double('Response')
      response_body = [{ id: 1, name: 'Курс 1' }, { id: 1, name: 'Курс 2' }].to_json
      allow(response).to receive(:body).and_return(response_body)

      allow(RestClient::Request).to receive(:execute).and_return(response)

      get "/index"

      # Checks if we have our cache inside mock Redis
      expect($REDIS.get('main_page_cache')).not_to be_empty
      expect($REDIS.get('last_available')).not_to be_empty
    end

    it 'takes the first page from cache in case of exception' do
      created_at = Time.now
      response_body = {courses: [{ id: 1, name: 'Курс 1' }, { id: 1, name: 'Курс 2' }], created_at: created_at}.to_json
      $REDIS.set('main_page_cache', response_body)
      $REDIS.set('last_available', Time.now - 1.day)
      allow(RestClient::Request).to receive(:execute).and_raise(RestClient::InternalServerError)

      get "/index"

      # Checks if we have our cache inside mock Redis
      expect(subject).to render_template(:index)
      # Cached page shouldn't have pagination
      expect(response.body).not_to match(/Previous/)
      expect(response.body).not_to match(/Next/)

      # Cached page should show us cached courses
      expect(response.body).to match(/Курс 1/)
      expect(response.body).to match(/Курс 2/)

      # Cached page should show us the creation date of the cache
      expect(response.body).to match(/Загружена копия от/)
      expect(response.body).to match(/#{created_at.to_formatted_s(:db)}/)
    end

    it 'shows the proper message if site is inactive for more than a day' do
      created_at = Time.now
      response_body = {courses: [{ id: 1, name: 'Курс 1' }, { id: 1, name: 'Курс 2' }], created_at: created_at}.to_json
      $REDIS.set('main_page_cache', response_body)
      $REDIS.set('last_available', Time.now - 2.day)
      allow(RestClient::Request).to receive(:execute).and_raise(RestClient::InternalServerError)

      get "/index"

      # Checks if we have our cache inside mock Redis
      expect(subject).to render_template(:index)
      # Cached page shouldn't have pagination
      expect(response.body).not_to match(/Previous/)
      expect(response.body).not_to match(/Next/)

      # Cached page should show us cached courses
      expect(response.body).to match(/Курс 1/)
      expect(response.body).to match(/Курс 2/)

      expect(response.body).to match(/Teachbase лежит уже 2 дней/)
      expect(response.body).to match(/Загружена копия от/)
      # Cached page should show us the creation date of the cache
      expect(response.body).to match(/#{created_at.to_formatted_s(:db)}/)
    end
  end
end
