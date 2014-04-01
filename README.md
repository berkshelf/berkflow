# Berkflow

A command line tool for managing Chef Environments using Berkshelf and the [Environment Cookbook Pattern](http://vialstudios.logdown.com/posts/166848-the-environment-cookbook-pattern).

## Installation

    $ gem install berkflow

## Usage

    $ blo help

### Upgrading a Chef Environment

Berkflow exposes a command for configuring a Chef Environment and running Chef Client on all nodes in that environment.

    $ blo upgrade myface-dev myface 1.2.3
    Applying cookbook locks to myface-dev...
    Discovering nodes in myface-dev...
    Running Chef Client on 10 nodes...
    Successfully ran Chef Client on 10 nodes
    Done. See berkflow_out/20140331172904 for logs.

Your Chef Server must meet the following requirements:

  * The `myface-dev` environment must exist
  * Version 1.2.3 of the myface cookbook (and it's dependencies) must be uploaded to the server
  * Version 1.2.3 of the myface cookbook must have a Berksfile.lock. A cookbook having a Berksfile.lock is said to be an "Environment Cookbook"

> Note: earlier versions of Berkshelf generated a chefignore file that included the Berksfile.lock. This will prevent your Berksfile.lock from being uploaded. Remove this line from the chefignore of your cookbook. This has been fixed in Berkshelf master and will ship with Berkshelf 3.0.

By default, the user you are logged into your current machine and your default id_rsa key will be used for SSH authentication. See the help menu for how to override SSH settings.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/berkflow/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
