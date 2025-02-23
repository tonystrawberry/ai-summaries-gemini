require "json"
require "net/http"
require 'dotenv/load'

##
# A Gemini class for summarizing text using the Gemini API.
#
# Example:
#   gemini = Gemini.summarize({very_long_text})
#
class Gemini
  BASE_URI = "https://generativelanguage.googleapis.com/v1beta/models/"

  # Instantiate the class and summarize a given text.
  def self.summarize(...)
    new.summarize(...)
  end

  # Initialize the Gemini class with the API token and model.
  # @param token [String] The API token.
  # @param model [String] The model to use.
  def initialize(token: ENV["GEMINI_API_KEY"], model: "gemini-2.0-flash")
    @token = token
    @model = model
  end

  # Summarize a given text.
  # @param text [String] The text to summarize.
  # @param length [String] The length of the summary.
  # @return [String] The summarized text.
  def summarize(text, length: "2-3 sentences")
    response = generate_content(
      contents: [{
        parts: [{ text: "Summarize this in #{length}: #{text}" }]
      }]
    )

    response.dig("candidates", 0, "content", "parts", 0, "text")
  end

  private

  # Call the generateContent endpoint.
  # @param args [Hash] The arguments to pass to the endpoint.
  # @return [Hash] The response from the endpoint.
  def generate_content(args)
    post("generateContent", body: args)
  end

  # Make a POST request to the given path.
  # @param path [String] The path to make the request to.
  # @param body [Hash] The body of the request.
  # @param headers [Hash] The headers of the request.
  # @return [Hash] The response from the request.
  def post(path, body:, headers: {"content-type": "application/json"})
    url = URI("#{BASE_URI}#{@model}:#{path}?key=#{@token}")
    data = JSON.dump(body)
    response = Net::HTTP.post(url, data, headers)

    unless response.is_a?(Net::HTTPSuccess)
      raise "Request failed with status code #{response.code}: #{response.body}"
    end

    JSON.parse(response.body)
  end
end

# Example usage
puts Gemini.summarize("""
  In this day and age, everyone is using video streaming platforms whether it is YouTube, Netflix or Amazon Prime video, all allowing you to watch videos in high quality.
  In this article, we will learn how to build a scalable video streaming application using AWS Elemental MediaConvert and Ruby on Rails.
  Building a big application like Netflix is certainly not an easy task so we will focus only on building a video streaming application that allows users to upload videos and watch them in different qualities, while providing a secure, scalable and performant solution.
""")