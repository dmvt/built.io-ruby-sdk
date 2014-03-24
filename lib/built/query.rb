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
    def initialize(class_uid=nil)
      @class_uid  = class_uid
      @params     = {
        "query" => {}
      }
    end

    # Where given key matches value
    # @param [String] key The key on which to search
    # @param [Object] value The value with which to match
    # @return [Query] self
    def where(key, value)
      @params["query"][key] = value

      self
    end

    # To check that the key has a value greater than the one specified
    # @param [String] key The key
    # @param [Object] value The value
    # @return [Query] self
    def greater_than(key, value)
      @params["query"][key] = {"$gt" => value}

      self
    end

    # To check that the key has a value greater than OR equaling the one specified
    # @param [String] key The key
    # @param [Object] value The value
    # @return [Query] self
    def greater_than_equal(key, value)
      @params["query"][key] = {"$gte" => value}

      self
    end

    # To check that the key has a value less than the one specified
    # @param [String] key The key
    # @param [Object] value The value
    # @return [Query] self
    def less_than(key, value)
      @params["query"][key] = {"$lt" => value}

      self
    end

    # To check that the key has a value less than OR equaling the one specified
    # @param [String] key The key
    # @param [Object] value The value
    # @return [Query] self
    def less_than_equal(key, value)
      @params["query"][key] = {"$lte" => value}

      self
    end

    # To check that the key has a value not equaling the one specified
    # @param [String] key The key
    # @param [Object] value The value
    # @return [Query] self
    def not_equal(key, value)
      @params["query"][key] = {"$ne" => value}

      self
    end

    # Sort results in ascending order for the given key
    # @param [String] key The key by which to sort
    # @return [Query] self
    def ascending(key)
      @params["asc"] = key

      self
    end

    # Sort results in descending order for the given key
    # @param [String] key The key by which to sort
    # @return [Query] self
    def descending(key)
      @params["desc"] = key

      self
    end

    # To check that the value for a key is contained in a given array
    # @param [String] key The key to check
    # @param [Array] array An array of values
    # @return [Query] self
    def contained_in(key, array)
      @params["query"][key] = {"$in" => array}

      self
    end

    # To check that the value for a key is NOT contained in a given array
    # @param [String] key The key to check
    # @param [Array] array An array of values
    # @return [Query] self
    def not_contained_in(key, array)
      @params["query"][key] = {"$nin" => array}

      self
    end

    # To check that the given key exists
    # @param [String] key
    # @return [Query] self
    def exists(key)
      @params["query"][key] = {"$exists" => true}

      self
    end

    # To check that the given key does not exist
    # @param [String] key
    # @return [Query] self
    def not_exists(key)
      @params["query"][key] = {"$exists" => false}

      self
    end

    # Reference query a field
    # @param [String] key
    # @param [Query] query
    def in_query(key, query)
      @params["query"][key] = {"$in_query" => query.params["query"]}

      self
    end

    # Reference query a field negatively
    # @param [String] key
    # @param [Query] query
    def not_in_query(key, query)
      @params["query"][key] = {"$nin_query" => query.params["query"]}

      self
    end

    # Limit the number of results to a given number
    # @param [Number] number
    # @return [Query] self
    def limit(number)
      @params["limit"] = number

      self
    end

    # Skip a give number of results
    # @param [Number] number
    # @return [Query] self
    def skip(number)
      @params["skip"] = number

      self
    end

    # Return the count of objects instead of the result of the query
    # @return [Query] self
    def count
      @params["count"] = true

      self
    end

    # Include the count of objects matching the query in the result
    # @return [Query] self
    def include_count
      @params["include_count"] = true

      self
    end

    # Include reference fields in the response (joins)
    # @param [String] key The reference field to include
    # @return [Query] self
    def include(key)
      @params["include"] ||= []
      @params["include"] << key

      self
    end

    # Include the owner of the object in the parameter _owner
    # @return [Query] self
    def include_owner
      @params["include_owner"] = true

      self
    end

    # Include draft objects that haven't been published yet
    # @return [Query] self
    def include_drafts
      @params["include_unpublished"] = true

      self
    end

    # Include the schema of the class in the result
    # @return [Query] self
    def include_schema
      @params["include_schema"] = true

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
        Built.client.request(uri, :get, nil, @params).parsed_response,
        @class_uid
      )
    end
  end

  class QueryResponse
    # Get objects in the response
    # @return [Array] objects
    def objects
      @objects
    end

    # Get the count of objects
    # @return [Number] count
    def count
      @count
    end

    # Get the included schema
    # @return [Hash] schema
    def schema
      @schema
    end

    private

    def initialize(response, class_uid)
      @response   = response

      if response["objects"].is_a?(Array)
        @objects  = response["objects"].map {|o| Built::Object.new(class_uid, o)}
      else
        @objects  = []
        @count    = response["objects"]
      end

      if response["count"]
        @count    = response["count"]
      end

      if response["schema"]
        @schema   = response["schema"]
      end
    end
  end
end