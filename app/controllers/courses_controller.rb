require 'json'

class CoursesController < ApplicationController
  def index
    @page = permitted_params[:page] || '1'
    @per_page = permitted_params[:per_page] || '2'
    redis_courses_service = RedisCoursesService.new

    begin
      @courses = JSON.parse(TeachbaseApiService.new
        .courses(page: @page, per_page: @per_page, headers: headers))

      redis_courses_service.cache_courses_in_redis(courses: @courses) if @page == '1'
      redis_courses_service.update_last_available_in_redis
    rescue RestClient::Unauthorized
      @error = 'Срок действия токена истек, нужно получить новый'
      redirect_to action: 'login'
    rescue RestClient::InternalServerError, RestClient::Exceptions::OpenTimeout => e
      data = redis_courses_service.restore_data_from_redis
      @courses = data[:courses]
      @last_available = data[:last_available]
      @error = data[:error]
    rescue StandardError
      puts 'Unhandled exception!!! How come?!!'
    end
  end

  def login; end

  def api_key
    response = TeachbaseApiService.new.api_key(client_id: ENV['CLIENT_ID'], client_secret: ENV['CLIENT_SECRET'])

    token = JSON.parse(response)['access_token']

    cookies[:teachbase_token] = {
      value: token,
      expires: 1.year.from_now
    }

    redirect_to action: 'index'
  end

  private

  def headers
    headers = {
      'Authorization' => "Bearer #{cookies[:teachbase_token]}",
      'accept' => 'application/json'
    }
  end

  def permitted_params
    params.permit(:per_page, :page)
  end
end
