twitch-plays-server
================================

### Description

Based on [TwitchPlaysPokemon](http://www.twitch.tv/twitchplayspokemon), this is a simple library that watches
an IRC channel for input and relays those as commands to a [RabbitMQ](https://www.rabbitmq.com) messaging
server.  From there any client that subscribes to the appropriate queue can receive the commands.

### Configuration

You will need to create a "configuration.yml" file containing your IRC and RabbitMQ configuration.
There is a file with examples in <code>example-configuration.yml</code>

### Deployment

I have a Vagrantfile here, but it probably won't be much use with my custom roles.  Basically you need to
have RabbitMQ running with the proper setup and credentials for this to work.

### Usage

Run <code>bundle install</code> to install gem dependencies.  Then run the following:

    ruby twitch-plays.rb

Tests can be run by typing <code>rake</code> or <code>rspec spec</code>.
