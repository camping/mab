Mab
===

Markup as Ruby; in a fast, concise and feature-rich way this time.

Examples
--------

Extending an object:

```ruby
r = Object.new
r.extend Mab::Mixin::HTML5
r.extend Mab::Indentation

r.mab do
  doctype!
  html do
    
  end
end

```

Using Mab::Builder:

```ruby
class Person
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def awesome?; true end
end

# Assign instance variables:
Mab::Builder.new(:person => Person.new('BitBuffin')) do
  if @person.awesome?
    h1 @person.name
  else
    p @person.name
  end
end.to_s

# Use helper (methods and instance variables will be available):
Mab::Builder.new({}, Person.new('BitPuffin')) do
  if awesome?
    h1 @name
  else
    p @name
  end
end
```

