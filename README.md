# built.io

built.io is a Backend-as-a-Service. This is the ruby SDK providing convenient
wrappers for working with built.io.

## Installing

```ruby
gem install built.io
```

## Getting Started

Call the `init` method on `Built` to initialize the SDK with your
application's api_key:

```ruby
Built.init :application_api_key => "<your api key>"
```

## Objects

### Create an object

```ruby
obj = Built::Object.new("people")

obj["name"] = "James"
obj["age"]  = 32

obj.save
```

### Update an existing object

If you already have objects from a query, just set the attributes and save:

```ruby
obj["age"] = 43
obj.save
```

If you just have the object's `uid`, set it first:

```ruby
obj.uid = "bltMyU1d"
obj["age"] = 43
obj.save
```

### Delete an object

```ruby
obj.destroy
```

## Querying objects

```ruby
query = Query.new("people")
query
  .containedIn("name", ["James"])
  .greaterThan("age", 30)
  .include_count

result = query.exec

puts result.objects[0]
puts result.count
```