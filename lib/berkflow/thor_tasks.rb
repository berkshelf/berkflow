require 'berkshelf'
require 'octokit'
require 'ridley/chef/cookbook'

module Berkflow
  class ThorTasks < Thor
    namespace "blo"

    REGEX = /(git\@github.com\:|https\:\/\/github.com\/)(.+).git/.freeze

    method_option :berksfile,
      type: :string,
      default: Berkshelf::DEFAULT_FILENAME,
      desc: "Path to a Berksfile to operate off of.",
      aliases: "-b",
      banner: "PATH"
    method_option :github_token,
      type: :string,
      default: ENV["GITHUB_TOKEN"],
      required: true,
      aliases: "-t",
      banner: "TOKEN"
    desc "release", "Create a Github Release for the current cookbook version."
    def release
      cookbook = Ridley::Chef::Cookbook.from_path(File.dirname(options[:berksfile]))
      begin
        say "Creating GitHub release (#{cookbook.version})"
        release = github_client.create_release(repository, cookbook.version)
      rescue Octokit::UnprocessableEntity
        say "Release already exists, skipping..."
        release = github_client.releases(repository).find { |release| release[:tag_name] == cookbook.version }
      end

      berksfile = Berkshelf::Berksfile.from_file(options[:berksfile])
      pkg_dir   = File.join(File.dirname(File.expand_path(berksfile.filepath)), "pkg")
      out_file  = File.join(pkg_dir, "cookbooks-#{Time.now.to_i}.tar.gz")
      FileUtils.mkdir_p(pkg_dir)
      berksfile.package(out_file)

      begin
        say "Uploading #{File.basename(out_file)} to GitHub..."
        github_client.upload_asset(release[:url], out_file, name: "cookbooks.tar.gz", content_type: "application/x-tar")
      rescue Errno::EPIPE; end
    end

    private

      def github_client
        @github_client ||= Octokit::Client.new(access_token: options[:github_token])
      end

      def repository
        @repository ||= extract_repository
      end

      def extract_repository
        _, repository = `git remote show origin | grep Push`.scan(REGEX).first
        repository
      end
  end
end
