# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "hash-utils/object"   # >= 0.18.0
require "command-builder"     # >= 0.2.0
require "unix/whereis"
require "set"

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
    
    BOOLEAN_ARGS = Set::new [
        :optimize, :progressive, :grayscale, :perfect, :transpose, 
        :transverse, :trim, :arithmetic
    ]
    
    ##
    # Holds copy values.
    #
    
    COPY_OPTIONS = Set::new [
        :none, :comments, :all
    ]
    
    ##
    # Holds flip values.
    #
    
    FLIP_OPTIONS = Set::new [
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
            if v.kind_of? TrueClass and self::BOOLEAN_ARGS.include? k 
                cmd << k
            end
        end
        
        # Rotate
        if options[:rotate].kind_of? Integer
            cmd.arg(:rotate, options[:rotate].to_i)
        elsif options.include? :rotate
            raise Exception::new("Invalid value for :rotate option. Integer expected.")
        end
        
        # Rotate
        if options[:restart].kind_of? Integer
            cmd.arg(:restart, options[:restart].to_i)
        elsif options.include? :restart
            raise Exception::new("Invalid value for :restart option. Integer expected.")
        end
        
        # Crop
        if options[:crop].kind_of? String
            cmd.arg(:crop, options[:crop].to_s)
        elsif options.include? :crop
            raise Exception::new("Invalid value for :crop option. Structured string expected. See 'jpegtran' reference.")
        end
        
        # Scans
        if options[:scans].kind_of? String
            cmd.arg(:scans, options[:scans].to_s)
        elsif options.include? :scans
            raise Exception::new("Invalid value for :scans option. String expected.")
        end
                
        # Copy
        if options.include? :copy 
            value = options[:copy].to_sym
            if self::COPY_OPTIONS.include? value
                cmd.arg(:copy, value)
            else
                raise Exception::new("Invalid value for :copy. Expected " << self::COPY_OPTIONS.to_s)
            end
        end 
        
        # Flip
        if options.include? :flip
            value = options[:flip].to_sym
            if self::FLIP_OPTIONS.include? :value
                cmd.arg(:flip, value)
            else
                raise Exception::new("Invalid value for :flip. Expected " << self::FLIP_OPTIONS.to_s)
            end
        end
        
        # Outfile
        if options.include? :outfile
            if options[:outfile].kind_of? String
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
