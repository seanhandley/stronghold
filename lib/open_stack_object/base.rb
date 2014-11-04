require 'fog'
require 'audited-activerecord'
require_relative '../active_record/fake_model'

module OpenStackObject

  # Handle various object types available via OpenStack
  #
  # This class uses Fog to do the heavy lifting and acts as a lightweight
  # wrapper for all kinds of OpenStack objects. Subclasses inheriting from
  # this base class may define which methods and attributes they care about
  # in the underlying Fog object, as well as call service-level methods via
  # Fog itself. See the Fog project documentation and code for details of
  # how it represents and interacts with the OpenStack API.
  #
  # Note: Debugging can be carried out by calling self.send(:obj).inspect
  #
  class Base
    include ActiveModel::Model
    include ActiveRecord::FakeModel

    def initialize(obj)
      @obj = obj
    end

    # Meaningful representation of an OpenStack object
    #
    # e.g.
    # 
    #   instance.to_s # => #<OpenStack::Instance:23122dfc-8aee-421a-8503-874c92ab0900 @name="Foo", @state="ACTIVE", @all_addresses=[]>
    #
    def to_s
      "#<#{self.class.to_s}:#{id} #{@@attributes.collect{|d| "@#{d}=#{send(d.to_sym).inspect}"}.join ', '}>"
    end

    # UUID of the OpenStack object
    #
    # e.g.
    #   23122dfc-8aee-421a-8503-874c92ab0900
    #
    def id
      obj.id
    end

    def inspect
      to_s
    end

    # Destroys the given OpenStack object in the cluster.
    #
    # @raise [OpenStackObject::Error] if the object cannot be destroyed
    # @return [boolean] success
    def destroy
      obj.destroy
    end

    # Update a given OpenStack object
    #
    # @param [Hash] args a hash of arguments for updating the object
    # @raise [OpenStackObject::Error] if the object cannot be updated
    # @return [OpenStackObject::Base] Updated object
    def update(args)
      obj.update(args)
      args.each do |k,v|
        obj.send("#{k.to_sym}=", v)
      end
      self
    end

    class << self

      # Return all items in the supplied collection.
      #
      # @return [Array] of type [OpenStackObject::Base]
      def all
        conn.send(collection_name).map{|s| new s }
      end

      # Find all items in the supplied collection where the supplied
      # attribute is equal to the supplied value.
      #
      # @param [String] attribute the attribute to be queried
      # @param [String] value the value to be found
      # @return [Array] of type [OpenStackObject::Base] where the attribute matches the value
      def find_all_by(attribute, value)
        [conn.send(collection_name).find {|s| s.send(attribute.to_sym) == value}].flatten.compact.map do |s|
          new s  
        end
      end

      # Find an item matching the supplied ID.
      #
      # @param [String] id the ID of the item
      # @return [OpenStackObject::Base] Object with this ID, otherwise nil
      def find(id)
        result = [conn.send(collection_name).find {|s| s.id == id}].flatten.first
        result ? new(result) : nil
      end

      # Create a new OpenStack object
      #
      # @param [Hash] args a hash of arguments for creating the object
      # @raise [OpenStackObject::Error] if the object cannot be created
      # @return [OpenStackObject::Base] Newly created object
      def create(args)
        new conn.send(collection_name).create(args)
      end

      private

      def conn
        args = OPENSTACK_ARGS.dup
        if Authorization.current_user.present?
          username   = Authorization.current_user.email
          tenant     = Authorization.current_user.organization.primary_tenant.reference
          token      = Authorization.current_user.token
          args.merge!(:openstack_username   => username,
                      :openstack_auth_token => token,
                      :openstack_tenant     => tenant,
                      :openstack_api_key    => nil)
        end
        "Fog::#{object_name.to_s.titleize}".constantize.new(args)
      rescue NameError
        raise ArgumentError, "Invalid credentials"
      end

    end

    protected

    def audit(action)
      Audited::Adapters::ActiveRecord::Audit.create auditable: self, action: action, comment: self.name,
                   user: Authorization.current_user,
                   organization_id: Authorization.current_user.organization_id,
                   audited_changes: Hash[(@@attributes + ['id']).collect{|d| [d.to_s,self.send(d.to_sym)]}]
    end

    private

    # All OpenStack objects respond to these.
    def self.default_methods
      [:reload, :persisted?]
    end

    # Given a list of attributes, add them as method delegates to the underlying
    # OpenStack object.
    #
    # e.g.
    #
    #   class Instance < OpenStackObject::Base
    #     attributes :foo, :bar, :baz
    #   end
    #
    # These will be passed to the OpenStack object and its response returned.
    #
    def self.attributes(*args)
      @@attributes = args.each{|a| class_eval{|c| delegate a.to_sym, to: :obj}}
    end

    # Given a list of methods, add them as method delegates to the underlying
    # OpenStack object.
    #
    # e.g.
    #
    #   class Instance < OpenStackObject::Base
    #     methods :restart, :stop, :start
    #   end
    #
    # These will be passed to the OpenStack object and its response returned.
    #
    def self.methods(*args)
      args = [args + default_methods].uniq.flatten.compact
      args.each{|a| class_eval{|c| delegate a.to_sym, to: :obj}}
    end

    # The object we get back from OpenStack via the Fog gem
    def obj
      @obj
    end

    # Executes a raw service method on the Fog object.
    #
    # e.g.
    #
    #   service_method do |s|
    #     s.suspend_server(id)
    #   end
    #
    # @raise [OpenStackObject::Error] if there are API errors
    # @return [OpenStackObject::Base] returns self
    def service_method(&block)
      yield(obj.service)
      self
    rescue Excon::Errors::Conflict => e
      raise OpenStackObject::Error, api_error_message(e)
    rescue Fog::Compute::OpenStack::NotFound => e
      raise OpenStackObject::Error, 'Could not find that object'
    end

    def api_error_message(e)
      body = JSON.parse(e.response.data[:body])
      if body['conflictingRequest']
        return body['conflictingRequest']['message']
      else
        return body['error']['message']
      end
    end

  end

end