require 'eventmachine'
require 'em-http'

# Need by em-http on ruby 1.8 :(
unless "".respond_to?(:bytesize)
  class String
    alias :bytesize :size
  end
end

module RSolr
  
  class EMHttp
    
    include RSolr::Connectable
    
    attr_reader :url, :proxy, :options, :request_options
    
    def initialize options = {}
      super
      @options = options
      @url = options[:base_url]
      if options[:proxy]
        uri = URI.parse(options[:proxy])
        @proxy = {
          :host => uri.host,
          :port => uri.port,
          :authorization => [uri.user, uri.password]
        }
      end
    end

    def send_request(options)
      method = options[:method]
      options[:head] = options[:headers]
      options[:body] = options[:data]
      options[:proxy] ||= @proxy if @proxy
      
      @request_options = options
      uri = URI.parse("#{@url}#{options[:uri]}")
      
      http = EventMachine::HttpRequest.
        new(uri.to_s[/.*\?/][0..-2]).
        send(method, options.merge(:query => options[:query]))

      http.callback { |http|
        begin
          response_hash = {
            :body => http.response,
            :status => http.response_header.status,
            :headers => http.response_header
          }
          obj = options[:client].adapt_response(@request_options,
                                                response_hash)
          
          unless obj.is_a?(Hash)
            raise RSolr::Error::InvalidRubyResponse.new(@request_options, 
                                                        response_hash)
          end
          @request_options[:callback].call(options[:client],
                                           http,
                                           @request_options,
                                           obj)
        rescue RSolr::Error::InvalidRubyResponse => e
          if @request_options[:errback]
            @request_options[:errback].call(options[:client],
                                            http,
                                            @request_options,
                                            http.response)
          end
        end # begin/rescue clause
      }
      
      http.errback {
        p 'err'
        if @request_options[:errback]
          @request_options[:errback].call(options[:client],
                                          http,
                                          @request_options,
                                          http.response)
        end
      }
    end
    
  end # EMHttp
  
end # RSolr