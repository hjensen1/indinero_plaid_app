module Plaid
  class << self
    def search_institutions(params)
      Connection.get_request('/institutions/search', params)
    end

    def all_institutions
      
    end
  end

  class Connection
    class << self
      def get_request(path, options = {})
        uri = build_uri(path)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.get("#{uri.path}?#{options.to_param}")
        parse_get_response(response.body)
      end
    end
  end
end
