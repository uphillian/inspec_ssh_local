#!/opt/inspec/embedded/bin/ruby
# frozen_string_literal: true

require "inspec"
require "inspec/cli"

require_relative './inspec_ssh_local.rb'

Inspec::InspecCLI.start(ARGV, enforce_license: false)
