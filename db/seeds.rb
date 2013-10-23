puts "Loading seed data in the DB"

foxy = Song.create(name: 'Foxy', description: "The artist is Oblast", url: 'http://www.youtube.com/watch?v=a_rflWF-iBg')

c_jesus = Song.create(name: 'Chocolate Jesus', description: "The artist is Tom Waits", url: 'http://www.youtube.com/watch?v=m5kHx1itU8c')

ended  = Song.create(name: "Cause we've ended as lovers", description: "The artist is Jeff Beck", url: 'http://www.youtube.c')

golden = Song.create(name: 'Golden Age', description: "The artist is Beck", url: 'http://www.youtube.com/watch?v=Y6zAT15vaFk')

foo = User.create(email: 'foo@example.com', password: 'foo')
bar = User.create(email: 'bar@example.com', password: 'bar')

# foo.songs << foxy
# foo.songs << golden
# foo.save!

# bar.songs << c_jesus
# bar.save!
