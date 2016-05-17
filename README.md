# Play Alpha

A web application for playing chess against [Alpha](https://github.com/smichaelrogers/alpha)

[![ui](./screen.png)](https://www.playalpha.xyz)

---

## Live
[Play it here](http://www.playalpha.xyz)

[Original chess engine](https://github.com/smichaelrogers/alpha)



## Features
- Sinatra JSON API
- Chess interface built with JavaScript/jQuery/Sass
- Modified version of [Alpha](https://github.com/smichaelrogers/alpha) that logs search progress
- Redis storage of game results
- Load any game position from FEN


## Setup
Clone this repo, `brew install redis` on OS X, install Ruby dependencies with `bundle install`, then `rackup` to start the server and goto localhost:9292

---

## License
MIT