# rewrite the local transport to run ssh with commands instead

module Train::Transports
  class Foo < Train.plugin(1)
    name "foo"
    class PipeError < Train::TransportError; end

    def connection(_ = nil)
      @connection ||= Connection.new(@options)
    end

    class Connection < BaseConnection
      def initialize(options)
        super(options)
        @options = options
        @runner = GenericRunner.new(self, options)
      end
      def login_command
        nil # none, open your shell
      end

      def close
        @runner.close
      end

      def uri
        "foo://"
      end
      private
      def run_command_via_connection(cmd, &_data_handler)
        # Use the runner if it is available
        return @runner.run_command(cmd) if defined?(@runner)

        # If we don't have a runner, such as at the beginning of setting up the
        # transport and performing the first few steps of OS detection, fall
        # back to shelling out.
        res = Mixlib::ShellOut.new(cmd)
        res.run_command
        Foo::CommandResult.new(res.stdout, res.stderr, res.exitstatus)
      rescue Errno::ENOENT => _
        CommandResult.new("", "", 1)
      end

      def file_via_connection(path)
        if os.windows?
          Train::File::Remote::Windows.new(self, path)
        else
          Train::File::Remote::Unix.new(self, path)
        end
      end
    end
    class GenericRunner
        include_options Train::Extras::CommandWrapper

        def initialize(connection, options)
          @cmd_wrapper = Foo::CommandWrapper.load(connection, options)
          if not options.key?(:port)
            options[:port] = 22
          end
          @options = options
        end
        def run_command(cmd)
          cmd = """ssh -S /var/tmp/ansible-#{@options[:host]}-#{@options[:port]}-#{@options[:user]} #{@options[:user]}@#{@options[:host]} \"#{cmd}\""""

          if defined?(@cmd_wrapper) && !@cmd_wrapper.nil?
            cmd = @cmd_wrapper.run(cmd)
          end

          res = Mixlib::ShellOut.new(cmd)
          res.run_command
          Foo::CommandResult.new(res.stdout, res.stderr, res.exitstatus)
        end
        def run(cmd)
          puts('hello world')
          super
        end
    end
  end
end
