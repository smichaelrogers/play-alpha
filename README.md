# alpha
Very small Ruby chess engine


```shell
$ irb
2.2.1 :001 > load 'lib/alpha.rb'
 => true 
2.2.1 :002 > Alpha.autoplay
  Height: 2  Move: ♘ g1 →  f3  Score: 28
  Height: 3  Move: ♙ e2 →  e4  Score: 70
  Height: 4  Move: ♙ e2 →  e4  Score: 50


  ♜  ♞  ♝  ♛  ♚  ♝  ♞  ♜
  ♟  ♟  ♟  ♟  ♟  ♟  ♟  ♟
  _  _  _  _  _  _  _  _
  _  _  _  _  _  _  _  _
  _  _  _  _  ♙  _  _  _
  _  _  _  _  _  _  _  _
  ♙  ♙  ♙  ♙  _  ♙  ♙  ♙
  ♖  ♘  ♗  ♕  ♔  ♗  ♘  ♖
  ♙ e2 →  e4
  Score: 70(move) 66(position)
  Nodes: 44604 @ 21009.24/sec
  Height: 2  Move: ♟ e7 →  e5  Score: -70
  Height: 3  Move: ♟ e7 →  e5  Score: -50
  Height: 4  Move: ♟ e7 →  e5  Score: -70
  Height: 5  Move: ♟ e7 →  e5  Score: -65


  ♜  ♞  ♝  ♛  ♚  ♝  ♞  ♜
  ♟  ♟  ♟  ♟  _  ♟  ♟  ♟
  _  _  _  _  _  _  _  _
  _  _  _  _  ♟  _  _  _
  _  _  _  _  ♙  _  _  _
  _  _  _  _  _  _  _  _
  ♙  ♙  ♙  ♙  _  ♙  ♙  ♙
  ♖  ♘  ♗  ♕  ♔  ♗  ♘  ♖
  ♟ e7 →  e5
  Score: -73(move) -26(position)
  Nodes: 309786 @ 23334.42/sec
  Height: 2  Move: ♘ g1 →  f3  Score: 50
  Height: 3  Move: ♘ g1 →  f3  Score: 70
  Height: 4  Move: ♘ g1 →  f3  Score: 65


  ♜  ♞  ♝  ♛  ♚  ♝  ♞  ♜
  ♟  ♟  ♟  ♟  _  ♟  ♟  ♟
  _  _  _  _  _  _  _  _
  _  _  _  _  ♟  _  _  _
  _  _  _  _  ♙  _  _  _
  _  _  _  _  _  ♘  _  _
  ♙  ♙  ♙  ♙  _  ♙  ♙  ♙
  ♖  ♘  ♗  ♕  ♔  ♗  _  ♖
  ♘ g1 →  f3
  Score: 73(move) 70(position)
  Nodes: 57776 @ 21320.57/sec
  Height: 2  Move: ♟ f7 →  f6  Score: -70
  Height: 3  Move: ♟ f7 →  f6  Score: -65
  Height: 4  Move: ♟ d7 →  d6  Score: -73


```




# Alpha

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/alpha`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'alpha'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alpha

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/alpha.

