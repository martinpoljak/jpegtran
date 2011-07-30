# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "command-builder"     # >= 0.2.0
require "unix/whereis"
require "lookup-hash"
require "hash-utils/object"   # >= 0.18.0

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
    
    BOOLEAN_ARGS = LookupHash[
        :optimize, :progressive, :grayscale, :perfect, :transpose, 
        :transverse, :trim, :arithmetic
    ]
    
    ##
    # Holds copy values.
    #
    
    COPY_OPTIONS = LookupHash[
        :none, :comments, :all
    ]
    
    ##
    # Holds flip values.
    #
    
    FLIP_OPTIONS = LookupHash[
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
        return Whereis.available? self::COMMAND 
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
        cmd = CommandBuilder::new(self::COMMAND)
        cmd.separators = ["-", " ", "-", " "]
        
        # Turn on/off arguments
        options.each_pair do |k, v|
            if v.true? and k.in? self::BOOLEAN_ARGS
                cmd << k
            end
        end
        
        # Rotate
        if options[:rotate].kind_of? Integer
            cmd.arg(:rotate, options[:rotate].to_i)
        elsif :rotate.in? options
            raise Exception::new("Invalid value for :rotate option. Integer expected.")
        end
        
        # Rotate
        if options[:restart].kind_of? Integer
            cmd.arg(:restart, options[:restart].to_i)
        elsif :restart.in? options
            raise Exception::new("Invalid value for :restart option. Integer expected.")
        end
        
        # Crop
        if options[:crop].string?
            cmd.arg(:crop, options[:crop].to_s)
        elsif :crop.in? options
            raise Exception::new("Invalid value for :crop option. Structured string expected. See 'jpegtran' reference.")
        end
        
        # Scans
        if options[:scans].string?
            cmd.arg(:scans, options[:scans].to_s)
        elsif :scans.in? options
            raise Exception::new("Invalid value for :scans option. String expected.")
        end
                
        # Copy
        if :copy.in? options 
            value = options[:copy].to_sym
            if vlaue.in? self::COPY_OPTIONS
                cmd.arg(:copy, value)
            else
                raise Exception::new("Invalid value for :copy. Expected " << self::COPY_OPTIONS.to_s)
            end
        end 
        
        # Flip
        if :flip.in? options
            value = options[:flip].to_sym
            if value.in? self::FLIP_OPTIONS
                cmd.arg(:flip, value)
            else
                raise Exception::new("Invalid value for :flip. Expected " << self::FLIP_OPTIONS.to_s)
            end
        end
        
        # Outfile
        if :outfile.in? options
            if options[:outfile].string?
                value = options[:outfile].to_s
            else
                raise Exception::new("Invalid value for :outfile option. String expected.")
            end
        else
            value = path.to_s
        end
        
        cmd.arg(:outfile, value)
        
        # Runs the command
        cmd << path.to_s
        
        if options[:debug] == true
            STDERR.write cmd.to_s + "\n"
        end
            
        # Blocking
        if block.nil?
            cmd.execute!

        # Non-blocking
        else
            cmd.execute do |output|
                block.call()
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
