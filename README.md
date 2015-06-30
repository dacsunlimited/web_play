[![Stories in Ready](https://badge.waffle.io/bitsuperlab/web_play.png?label=ready&title=Ready)](https://waffle.io/bitsuperlab/web_play)
# DAC PLAY GUI (web wallet)

This repository holds the DAC PLAY graphical user interface, also
known as the web wallet.  The web wallet is wrapped by the Qt client
and released as part of the platform-specific DAC PLAY binaries.

## Hacking

To start hacking on the GUI, first follow the directions to build the DAC PLAY client.

* Windows <https://github.com/dacsununlimited/bitshares/blob/master/BUILD_WIN32.md>
* OSX <https://github.com/dacsununlimited/bitshares/blob/master/BUILD_OSX.md>
* Ubuntu <https://github.com/dacsununlimited/bitshares/blob/master/BUILD_UBUNTU.md>

Install Node.js (<http://nodejs.org/download/>)

Install Ruby (if you don't have one installed yet)

    $ sudo apt-get update
    $ sudo apt-get install ruby-full rubygems #ubuntu

or

    $ \curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled #install latest ruby via rvm

Install Compass

    $ bundle install

Navigate to the web_wallet directory where `package.json` is located and run these commands:

    $ npm install
    $ npm start

Edit htdocs parameter in config.json  `AppData/Roaming/DAC PLAY` to point to the `web_wallet/generated/` directory.  For example: ` "htdocs": "C:/dac play/web_wallet/generated" `

Start another shell, navigate to `/bin/programs/client/RelWithDebInfo` directory, and start
the BitShares client:

    $ ./play_client --server \
        --rpcuser=test --rpcpassword=test \
        --httpdendpoint=127.0.0.1:5000
(You could also achieve this by changing these parameters in your config file.)

The client finds the local GUI code and launches a web server, which
you can access by opening <http://localhost:5000>.  

As long as you keep `npm start` running, the app will automatically be
recompiled (into the `generated/` directory) whenever you make any
changes to the source files in `app/`.

You will want to start by looking at `app/js/app.coffee` and then
browsing the `app/templates` and `app/js/controllers` directories.

## Notes

* If you are using Debian or Ubuntu, you may need to install the
  `nodejs-legacy` package before you run `npm install`.

* The Lineman.js framework (<http://linemanjs.com/>) is responsible
  for most of the features in the development environment.
