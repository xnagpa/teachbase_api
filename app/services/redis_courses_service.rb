class RedisCoursesService
  def restore_data_from_redis
    cache = JSON.parse($REDIS.get('main_page_cache'))

    courses = cache['courses']
    created_at = Time.parse(cache['created_at'])
    last_available = Time.parse($REDIS.get('last_available')).to_date
    days_off = (Time.now.to_date - last_available).to_i

    error = if days_off > 1
              "Teachbase лежит уже #{days_off} дней. Загружена копия от #{created_at}"
            else
              "В данный момент Teachbase недоступен. Загружена копия от #{created_at}"
            end

    { courses: courses, last_available: last_available, error: error }
  end

  def cache_courses_in_redis(courses:)
    $REDIS.set('main_page_cache', { courses: courses, created_at: Time.now }.to_json)
  end

  def update_last_available_in_redis
    $REDIS.set('last_available', Time.now.to_json)
  end
end
