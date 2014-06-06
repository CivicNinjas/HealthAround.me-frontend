# Frontend code for [healtharound.me](http://healtharound.me)

### What it does
* [Stylus](http://learnboost.github.io/stylus) files and [Nib](http://visionmedia.github.io/nib/) to CSS
* [CoffeeScript](http://coffeescript.org/) files to Javascript
* Serves your static files to localhost:9001
* Reloads your browser with LiveReload when files change

## Getting things up and running
- Install [Node.js](http://nodejs.org)

```
 git clone git@github.com:CivicNinjas/HealthAround.me-frontend.git
 cd <your project name>
 npm install
 npm install bower -g
 bower install
 npm start
 open http://localhost:9001 in your browser
````
## CLI Commands
* npm install
    * Installs server-side dependencies from NPM and client-side dependencies from Bower
* npm start
    * Compiles your files, starts watching files for changes, serves static files to port 9001
* npm run build
    * Builds everything

Minification, uglification and other tasks you're expected to run before deploying your product can be made by running the build command with env variable NODE_ENV set to "production"

    NODE_ENV=production npm run build

## Development guidelines
* **public** - directory should be dedicated only to compiled/copied files from **src** - directory.
  It should be possible to delete directory completely and after **npm start** or **npm run build** everything should be as they were before the deletation.
* All backend dependencies should be installed with **npm**. Browser dependencies should be installed with **bower** or with **npm**.

### Adding 3rd party libraries

    bower install jquery --save

*More specific instructions to follow and revamp of js_libs gulp task*

### Enable LiveReload
Install [LiveReload for Chrome](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en)
