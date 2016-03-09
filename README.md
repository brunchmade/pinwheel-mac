## Running Locally

* Copy `.env.sample` -> `.env` and fill out required keys: `PUSHER_URL`, `PUSHER_KEY`, `SOUNDCLOUD_ID`, `SOUNDCLOUD_SECRET`.
* Run `bundle install`.
* Run `bundle exec db:setup`.
* Start your Redis server, typically by running `redis-server`.
* Start your Rails server by running `foreman start`.
* Visit `http://localhost:5000`.

## Building the Electron Apps

We use [Electron](https://github.com/atom/electron) to build the Mac app wrapper. To compile your own binaries, run the following scripts from the project root:

### Install the `electron` command globally in your $PATH
`npm install electron-prebuilt -g`

**Production app**
`cd electron && npm run mac && cd ..`

**Development app**
`cd electron-beta && npm run mac && cd ..`

Your binary will be created in your `/Applications` folder.

## Environment Variables

Key | Required? | Notes
--- | --------: | -----
`PUSHER_KEY` | :heavy_check_mark: |
`PUSHER_URL` | :heavy_check_mark: |
`SECRET_KEY_BASE` | :heavy_check_mark: |
`SOUNDCLOUD_ID` | :heavy_check_mark: |
`SOUNDCLOUD_REDIRECT` | :heavy_check_mark: |
`SOUNDCLOUD_SECRET` | :heavy_check_mark: |
`BUGSNAG_AUTHENTICATION` | |
`BUNDLE_GEMFILE` | |
`DATABASE_HOST` | |
`DATABASE_PORT` | |
`MAX_THREADS` | |
`PORT` | |
`SKYLIGHT_AUTHENTICATION` | |
`RACK_ENV` | |
`WEB_CONCURRENCY` | |
