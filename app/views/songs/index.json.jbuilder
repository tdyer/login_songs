json.array!(@songs) do |song|
  json.extract! song, :name, :description, :url
  json.url song_url(song, format: :json)
end
