## Dependencies

You must have redis installed and running on the default port:6379 (or configure it in config/redis/cable.yml).

### Installing Redis
##### On Linux
* `wget http://download.redis.io/redis-stable.tar.gz`
* `tar xvzf redis-stable.tar.gz`
* `cd redis-stable`
* `make`
* `make install`

##### On Mac
* `brew install redis`

###### Note: You must have Ruby 2.2.2 installed in order to use redis

## Starting the servers

1. Run `./bin/setup`
3. Open up a separate terminal and run: `./bin/rails server`
4. One more terminal to run redis server: `redis-server`
4. Visit `http://localhost:3000`

## Live comments example

1. Open two browsers with separate cookie spaces (like a regular session and an incognito session).
2. Login as different people in each browser.
3. Go to the same message.
4. Add comments in either browser and see them appear real-time on the counterpart screen.

## Building the Electron apps

We use [Electron](https://github.com/atom/electron) to build the Mac app wrapper. To compile your own binaries, run the following scripts from the project root:

# Install the `electron` command globally in your $PATH
`npm install electron-prebuilt -g`

**Production app**
`cd electron && npm run pack && cd ..`

**Development app**
`cd electron-beta && npm run pack && cd ..`

Your binary will be created in your `/Applications` folder.
