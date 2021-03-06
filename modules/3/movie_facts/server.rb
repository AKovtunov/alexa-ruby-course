require 'sinatra'
require 'json'
require 'imdb'

post '/' do 
  parsed_request = JSON.parse(request.body.read)

  if parsed_request["request"]["intent"]["name"] == "AMAZON.StartOverIntent"
    return {
      version: "1.0",
      response: {
        sessionAttributes: {},
        outputSpeech: {
          type: "PlainText",
          text: "OK, what movie would you like to know about?"
        },
        shouldEndSession: false
      }
    }.to_json
  end

  if parsed_request["request"]["intent"]["name"] == "MovieFacts"
    requested_movie = parsed_request["request"]["intent"]["slots"]["Movie"]["value"]
    movie_list = Imdb::Search.new(requested_movie).movies
    movie = movie_list.first

    return { 
      version: "1.0",
      sessionAttributes: {
        movieTitle: requested_movie
      },
      response: {
        outputSpeech: {
            type: "PlainText",
            text: movie.plot_synopsis
          }
      }
    }.to_json
  end

  if parsed_request["request"]["intent"]["name"] == "FollowUp"
    movie_title = parsed_request["session"]["attributes"]["movieTitle"]
    movie_list = Imdb::Search.new(movie_title).movies
    movie = movie_list.first

    role = parsed_request["request"]["intent"]["slots"]["Role"]["value"]

    if role == "directed"
      response_text = "#{movie_title} was directed by #{movie.director.join}"
    end

    if role == "starred in"
      response_text = "#{movie_title} starred #{movie.cast_members.join(", ")}"
    end

    return {
      version: "1.0",
      sessionAttributes: {
        movieTitle: movie_title
      },
      response: {
        outputSpeech: {
          type: "PlainText",
          text: response_text
        }
      }
    }.to_json
  end
end