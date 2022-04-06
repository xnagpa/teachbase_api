require 'rest-client'
class TeachbaseApiService
  TIMEOUT = 5
  def api_key(client_id:, client_secret:)
    RestClient.post 'https://go.teachbase.ru/oauth/token', {
      grant_type: 'client_credentials',
      client_id: 'StTBsz5cFrXjcoDn28PshpQwpgYaA_NvVPPxjLfJzMk', # StTBsz5cFrXjcoDn28PshpQwpgYaA_NvVPPxjLfJzMk
      client_secret: 'ctvAonYx5JGIjcbdDhV_rXNksUMEYCWI6LC32yOLcgs' # ctvAonYx5JGIjcbdDhV_rXNksUMEYCWI6LC32yOLcgs
    }
  end

  def courses(page:, per_page:, headers:)
    RestClient::Request.execute(
      method: :get,
      url: "https://go.teachbase.ru/endpoint/v1/courses?page=#{page}&per_page=#{per_page}",
      timeout: TIMEOUT, headers: headers
    ).body
  end
end
