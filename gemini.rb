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

  # Instantiate the class and extract names from a given text.
  def self.extract_names(...)
    new.extract_names(...)
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

  # Extract names from a given text.
  # @param text [String] The text to extract names from.
  # @param length [String] The length of the summary.
  # @return [String] The extracted names.
  def extract_names(text, length: "2-3 sentences")
    response = generate_content(
      contents: [{
        parts: [{ text: "Extract person names from: #{text}" }]
      }],
      generationConfig: {
        response_mime_type: "application/json",
        response_schema: {
          type: "ARRAY",
          items: {
            type: "OBJECT",
            properties: {
              first_name: { type: "STRING" },
              last_name: { type: "STRING" }
            }
          }
        }
      }
    )

    JSON.parse(response.dig("candidates", 0, "content", "parts", 0, "text"))
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