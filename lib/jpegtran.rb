# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require 'pipe-run'

##
# The +jpegtran+ tool command frontend.
# @see http://linux.die.net/man/1/jpegtran
#

module Jpegtran

    ##
    # Holds +jpegoptim+ command.
    #

    COMMAND = :jpegtran

    ##
    # Indicates turn on/off style arguments.
    #

    BOOLEAN_ARGS = [
        :optimize, :progressive, :grayscale, :perfect, :transpose,
        :transverse, :trim, :arithmetic
    ]

    ##
    # Holds copy values.
    #

    COPY_OPTIONS = [
        :none, :comments, :all
    ]

    ##
    # Holds flip values.
    #

    FLIP_OPTIONS = [
        :horizontal, :vertical
    ]

    ##
    # Result structure.
    #
    # Return value contains only +:errors+ member. +:errors+ contains
    # simply array of error messages.
    #

    Result = Struct::new(:errors)

    ##
    # Holds output matchers.
    #

    ERROR = /jpegtran:\s*(.*)\s*/

    ##
    # Checks if +jpegtran+ is available.
    # @return [Boolean] +true+ if it is, +false+ in otherwise
    #

    def self.available?
        self.executable != nil
    end

    ##
    # Returns the jpegtran command executable full path
    # @return [String] path to the jpegtran executable
    #

    def self.executable
        path = `which #{self::COMMAND}`
        $? == 0 ? path.chomp! : nil
    end

    ##
    # Performs optimizations above file. For list of arguments, see
    # reference of +jpegtran+.
    #
    # If block is given, runs +jpegoptim+ asynchronously. In that case,
    # +em-pipe-run+ file must be already required.
    #
    # @param [String, Array] paths file path or array of paths for optimizing
    # @param [Hash] options options
    # @param [Proc] block block for giving back the results
    # @return [Struct] see {Result}
    #

    def self.optimize(path, options = { }, &block)

        # Command
        cmd = [self.executable]

        # Turn on/off arguments
        options.each_pair do |k, v|
            if v == true and self::BOOLEAN_ARGS.include?(k)
                cmd << "-#{k}"
            end
        end

        # Integer arguments
        [ :rotate, :restart ].each do |arg|
            if options[arg].kind_of? Integer
                cmd << "-#{arg} #{options[arg]}"
            elsif options.include?(arg)
                raise Exception::new("Invalid value for :#{arg} option. Integer expected.")
            end
        end

        # String arguments
        [ :crop, :scans ].each do |arg|
            if options[arg].is_a?(String)
                cmd << "-#{arg} #{options[arg]}"
            elsif options.include?(arg)
                raise Exception::new("Invalid value for :#{arg} option. Structured string expected. See 'jpegtran' reference.")
            end
        end

        # Copy
        if options.include?(:copy)
            value = options[:copy].to_sym
            if self::COPY_OPTIONS.include?(value)
                cmd << "-copy #{value}"
            else
                raise Exception::new("Invalid value for :copy. Expected " << self::COPY_OPTIONS.to_s)
            end
        end

        # Flip
        if options.include?(:flip)
            value = options[:flip].to_sym
            if self::FLIP_OPTIONS.include?(value)
                cmd << "-flip #{value}"
            else
                raise Exception::new("Invalid value for :flip. Expected " << self::FLIP_OPTIONS.to_s)
            end
        end

        # Outfile
        if options.include?(:outfile)
            if options[:outfile].is_a?(String)
                value = options[:outfile].to_s
            else
                raise Exception::new("Invalid value for :outfile option. String expected.")
            end
        else
            value = path.to_s
        end

        cmd << "-outfile #{value}"
        cmd << path.to_s
        cmd = cmd.join(" ")

        if options[:debug] == true
            STDERR.write cmd + "\n"
        end

        if block.nil?
            Pipe::run(cmd)
        else
            Pipe::run(cmd) do |output|
                block.call
            end
        end

    end


    # private
    #
    ##
    # Parses output.
    #
    #
    # def self.__parse_output(output)
    #    errors = [ ]
    #    output.each_line do |line|
    #        if m = line.match(self::ERROR)
    #            errors << m[1]
    #        end
    #    end
    #
    #    return errors
    # end
end
