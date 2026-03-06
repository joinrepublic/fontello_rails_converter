require 'faraday'
require 'json'
require 'securerandom'

module FontelloRailsConverter
  class FontelloApi
    FONTELLO_HOST = "https://fontello.com".freeze

    def initialize(options)
      @config_file = options[:config_file]
      @session_id = options[:fontello_session_id]
      @fontello_session_id_file = options[:fontello_session_id_file]
    end

    # creates a new fontello session from config.json
    def new_session_from_config
      body, content_type = multipart_body_for_config
      response = Faraday.post(FONTELLO_HOST) do |request|
        request.headers['Content-Type'] = content_type
        request.body = body
      end

      @session_id = response.body
      persist_session
      @session_id
    end

    def session_url
      "#{FONTELLO_HOST}/#{session_id}"
    end

    def download_zip_body
      response = Faraday.get("#{session_url}/get")
      response.body.force_encoding("UTF-8")
    end

    private

    def session_id
      @session_id ||= read_or_create_session
    end

    def read_or_create_session
      if @fontello_session_id_file && File.exist?(@fontello_session_id_file)
        @session_id = File.read(@fontello_session_id_file)
        return @session_id unless @session_id == ""
      end

      new_session_from_config
    end

    def persist_session
      File.write(@fontello_session_id_file, @session_id)
    end

    def multipart_body_for_config
      boundary = "----fontello-#{SecureRandom.hex(16)}"
      file_content = File.binread(@config_file)

      body = []
      body << "--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"config\"; filename=\"#{File.basename(@config_file)}\"\r\n"
      body << "Content-Type: application/json\r\n\r\n"
      body << file_content
      body << "\r\n--#{boundary}--\r\n"

      [body.join, "multipart/form-data; boundary=#{boundary}"]
    end
  end
end
