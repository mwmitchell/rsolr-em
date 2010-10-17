require "eventmachine"
require "em-http"
require "rsolr"

# Need by em-http on ruby 1.8 :(
unless "".respond_to?(:bytesize)
  class String
    alias :bytesize :size
  end
end

module RSolr
  
  class EM
    
    def execute client, request_context
      method = request_context[:method]
      options = {}
      options[:head] = request_context[:headers] if request_context[:headers]
      options[:body] = request_context[:data] if request_context[:body].to_s
      options[:proxy] ||= request_context[:proxy] if request_context[:proxy]
      
      uri = request_context[:uri]
      http_request = EventMachine::HttpRequest.new(uri.to_s)
      http = http_request.send(method, options)
      
      success_cb = request_context[:success] || request_context[:callback]
      error_cb = request_context[:error] || request_context[:errback]
      
      http.callback { |http|
        begin
          response_hash = {
            :body => http.response,
            :status => http.response_header.status,
            :headers => http.response_header
          }
          solr_response = client.adapt_response(request_context, response_hash)
          success_cb_args = case success_cb.arity
          when 1
            [solr_response]
          when 2
            [solr_response, request_context]
          when 3
            [solr_response, request_context, response_hash]
          end
          success_cb.call *success_cb_args
        rescue
          if error_cb
            error_cb_args = case error_cb.arity
            when 1
              [$!]
            when 2
              [$!, request_context, response_hash]
            when 3
              [$!, request_context, response_hash]
            end
            error_cb.call *error_cb_args
          else
            raise $!
          end
        end # begin/rescue clause
      }
      http.errback {
        if error_cb
          error_cb.call request_context, {}, nil
        end
      }
      nil
    end
    
  end # EMHttp
  
end # RSolr