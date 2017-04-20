# coding: utf-8
# https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa の末尾のサンプルより。

class ComputerVision
  require 'net/http'
  require 'json'
  require './loadkey.rb'
  include LoadKey

  attr_accessor :uri, :request, :response

  def initialize()
    @uri = URI('https://westus.api.cognitive.microsoft.com/vision/v1.0/analyze')
    @uri.query = URI.encode_www_form(
      { # Request parameters
        'visualFeatures' => 'Adult',
        # 'details' => '{string}',
        'language' => 'en'}
    )

    @request = Net::HTTP::Post.new(@uri.request_uri)
    # Request headers
    @request['Content-Type'] = 'application/json'
    @request['Ocp-Apim-Subscription-Key'] =
      load_key("azure-computer-vision-key.txt")
  end
  
  def api(url) # { url: "https://pbs.twimg.com/..." }
    # Request body
    hash = { url: url }
    @request.body = JSON.generate(hash) # '{"url":"https://pbs.twimg.com/..."}'
    # @request.body = '{"url":"'+ url  +'"}'
    @response = Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https') do |http|
      http.request(@request)
    end
    return JSON.parse(@response.body)
  end
  
end

