module Built
  # Perform a query on objects of a class
  class Query
    attr_accessor :params

    # Create a new query
    # @param [String] class_uid The uid of the class for querying
    # @example
    #   query = Query.new("people")
    #
    #   query
    #     .containedIn("name", ["James"])
    #     .greaterThan("age", 30)
    #     .include_count
    #
    #   result = query.exec
    #
    #   puts result.objects[0]
    #   puts result.count
    def initialize(class_uid = nil)
      @class_uid = class_uid
      @params = {:query => {}}
    end

    # Where given field matches value
    # @param [String] field The field on which to search
    # @param [Object] value The value with which to match
    # @return [Query] self
    def where(field, value)
      @params[:query][field] = value
      self
    end

    # To check that the field has a value greater than the one specified
    # @param [String] field The field
    # @param [Object] value The value
    # @return [Query] self
    def greater_than(field, value)
      @params[:query][field] = {:$gt => value}
      self
    end

    # To check that the field has a value greater than OR equaling the one specified
    # @param [String] field The field
    # @param [Object] value The value
    # @return [Query] self
    def greater_than_equal(field, value)
      @params[:query][field] = {:$gte => value}
      self
    end

    # To check that the field has a value less than the one specified
    # @param [String] field The field
    # @param [Object] value The value
    # @return [Query] self
    def less_than(field, value)
      @params[:query][field] = {:$lt => value}
      self
    end

    # To check that the field has a value less than OR equaling the one specified
    # @param [String] field The field
    # @param [Object] value The value
    # @return [Query] self
    def less_than_equal(field, value)
      @params[:query][field] = {:$lte => value}
      self
    end

    # To check that the field has a value not equaling the one specified
    # @param [String] field The field
    # @param [Object] value The value
    # @return [Query] self
    def not_equal(field, value)
      @params[:query][field] = {:$ne => value}
      self
    end

    # Sort results in ascending order for the given field
    # @param [String] field The field by which to sort
    # @return [Query] self
    def ascending(field)
      @params[:asc] = field
      self
    end

    # Sort results in descending order for the given field
    # @param [String] field The field by which to sort
    # @return [Query] self
    def descending(field)
      @params[:desc] = field
      self
    end

    # To check that the value for a field is contained in a given array
    # @param [String] field The field to check
    # @param [Array] array An array of values
    # @return [Query] self
    def contained_in(field, array)
      @params[:query][field] = {:$in => array}
      self
    end

    # To check that the value for a field is NOT contained in a given array
    # @param [String] field The field to check
    # @param [Array] array An array of values
    # @return [Query] self
    def not_contained_in(field, array)
      @params[:query][field] = {:$nin => array}
      self
    end

    # To check that the given field exists
    # @param [String] field
    # @return [Query] self
    def exists(field)
      @params[:query][field] = {:$exists => true}
      self
    end

    # To check that the given field does not exist
    # @param [String] field
    # @return [Query] self
    def not_exists(field)
      @params[:query][field] = {:$exists => false}
      self
    end

    # Reference query a field
    # @param [String] field
    # @param [Query] query
    def in_query(field, query)
      @params[:query][field] = {:$in_query => query.params[:query]}
      self
    end

    # Reference query a field negatively
    # @param [String] field
    # @param [Query] query
    def not_in_query(field, query)
      @params[:query][field] = {:$nin_query => query.params[:query]}
      self
    end

    # Select query a field for arbitrary references
    # @param [String] field The field to query
    # @param [String] class_uid of the class to query
    # @param [String] key to match
    # @param [Query] query to execute on the class
    def select_query(field, class_uid, key, query)
      @params[:query][field] = {
        :$select => {
          :key => key,
          :class_uid => class_uid,
          :query => query
        }
      }

      self
    end

    # Select query a field for arbitrary references, negatively
    # @param [String] field The field to query
    # @param [String] class_uid of the class to query
    # @param [String] key to match
    # @param [Query] query to execute on the class
    def dont_select_query(field, class_uid, key, query)
      @params[:query][field] = {
        :$dont_select => {
          :key => key,
          :class_uid => class_uid,
          :query => query
        }
      }

      self
    end

    # Get objects near a Location or an Object.
    # @param [Location, Object] location The location object or a Built::Object
    # @param [Fixnum] radius The radius in meters
    def near(location, radius)
      @params[:query][:$near] = {
        :coords => location.is_a?(Built::Location) ? location.to_arr : {
          :object => location.uid
        },
        :radius => radius
      }

      self
    end

    # Get objects within a set of location points
    # @param [Array<Location, Object>] Set of location points
    def within(points)
      @params[:query][:$within] = points.map do |point|
        point.is_a?(Built::Location) ? location.to_arr : {
          :object => location.uid
        }
      end

      self
    end

    # Limit the number of results to a given number
    # @param [Number] number
    # @return [Query] self
    def limit(number)
      @params[:limit] = number
      self
    end

    # Skip a give number of results
    # @param [Number] number
    # @return [Query] self
    def skip(number)
      @params[:skip] = number
      self
    end

    # Return the count of objects instead of the result of the query
    # @return [Query] self
    def count
      @params[:count] = true
      self
    end

    # Include the count of objects matching the query in the result
    # @return [Query] self
    def include_count
      @params[:include_count] = true
      self
    end

    # Include reference fields in the response (joins)
    # @param [String] field The reference field to include
    # @return [Query] self
    def include(field)
      @params[:include] ||= []
      @params[:include] << field
      self
    end

    # Include the owner of the object in the parameter _owner
    # @return [Query] self
    def include_owner
      @params[:include_owner] = true
      self
    end

    # Include draft objects that haven't been published yet
    # @return [Query] self
    def include_drafts
      @params[:include_unpublished] = true
      self
    end

    # Include the schema of the class in the result
    # @return [Query] self
    def include_schema
      @params[:include_schema] = true
      self
    end

    # Execute the query
    # @return [QueryResponse] response A hash containing the response
    def exec
      if !@class_uid
        raise BuiltError, I18n.t("querying.class_uid")
      end

      uri = Built::Object.uri(@class_uid)

      QueryResponse.new(
        Built.client.request(uri, :get, nil, @params).json,
        @class_uid
      )
    end
  end

  class QueryResponse
    # Get objects in the response
    # @return [Array] objects
    attr_reader :objects

    # Get the count of objects
    # @return [Number] count
    attr_reader :count

    # Get the included schema
    # @return [Hash] schema
    attr_reader :schema

    private

    def initialize(response, class_uid)
      @response = response

      case class_uid
      when Built::USER_CLASS_UID
        obj_class = Built::User
      when Built::ROLE_CLASS_UID
        obj_class = Built::Role
      when Built::INST_CLASS_UID
        obj_class = Built::Installation
      else
        obj_class = Built::Object
      end

      if response[:objects].is_a?(Array)
        @objects = response[:objects].map { |o|
          obj_class.new(class_uid).instantiate(o)
        }
      else
        # TODO: Investigate this... looks fishy
        @objects = []
        @count = response[:objects]
      end

      @count = response[:count] unless Util.blank?(response[:count])
      @schema = response[:schema] unless Util.blank?(response[:schema])
    end
  end
end
