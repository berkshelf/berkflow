require 'thor'
require 'berkflow'
require 'ridley'
require 'ridley-connectors'
require 'berkshelf'
require 'solve'
require 'tempfile'

module Berkflow
  class Cli < Thor
    desc "execute ENV CMD", "execute an arbitrary shell command on all nodes in an environment."
    def execute(environment, command)
      env = find_environment!(environment)

      say "Discovering nodes in #{environment}..."
      nodes = find_nodes(environment)

      if nodes.empty?
        say "No nodes in #{environment}. Done."
        exit(0)
      end

      say "Executing command on #{nodes.length} nodes..."
      nodes.each { |node| ridley.node.run(node.public_hostname, command) }

      say "Done."
    end

    desc "run_chef ENV", "run chef on all nodes in the given environment."
    def run_chef(environment)
      env = find_environment!(environment)

      say "Discovering nodes in #{environment}..."
      nodes = find_nodes(environment)

      if nodes.empty?
        say "No nodes in #{environment}. Done."
        exit(0)
      end

      say "Running Chef Client on #{nodes.length} nodes..."
      nodes.each { |node| ridley.node.chef_run(node.public_hostname) }

      say "Done."
    end

    desc "upgrade ENV APP VERSION", "upgrade an environment to a specific application version."
    def upgrade(environment, application, version)
      Berkshelf.logger.level = ::Logger::INFO
      validate_version!(version)
      env      = find_environment!(environment)
      cookbook = find_cookbook!(application, version)

      file = Tempfile.new("berkflow")
      unless contents = cookbook.download_file(:root_file, Berkshelf::Lockfile::DEFAULT_FILENAME, file.path)
        error "#{application} (#{version}) did not contain a Berksfile.lock"
        exit(1)
      end

      say "Applying cookbook locks to #{environment}..."
      lockfile = Berkshelf::Lockfile.from_file(file.path)
      unless lockfile.apply(environment)
        error "Failed to apply Berksfile.lock to #{environment}."
        exit(1)
      end

      say "Discovering nodes in #{environment}..."
      nodes = find_nodes(environment)

      if nodes.empty?
        say "No nodes in #{environment}. Done."
        exit(0)
      end

      say "Running Chef Client on #{nodes.length} nodes..."
      nodes.each { |node| ridley.node.chef_run(node.public_hostname) }

      say "Done."
    ensure
      file.close(true) if file
    end

    private

      def ridley
        @ridley ||= Ridley.new(server_url: config.chef.chef_server_url, client_name: config.chef.node_name,
          client_key: config.chef.client_key, ssh: { user: ENV["USER"], sudo: true })
      end

      def config
        Berkshelf::Config.instance
      end

      def validate_version!(version)
        Solve::Version.split(version)
        true
      rescue Solve::Errors::InvalidVersionFormat
        error "Invalid version: #{version}. Provide a valid SemVer version string. (i.e. 1.2.3)."
        exit(1)
      end

      def find_cookbook!(application, version)
        unless cookbook = ridley.cookbook.find(application, version)
          error "Cookbook not found: #{application} (#{version})."
          exit(1)
        end
        cookbook
      end

      def find_environment!(environment)
        unless env = ridley.environment.find(environment)
          error "Environment not found: #{environment}"
          exit(1)
        end
        env
      end

      def find_nodes(environment)
        ridley.search(:node, "chef_environment:#{environment}")
      end
  end
end
