Mab (Markup as Ruby)
====================

Mab let's you write HTML in plain Ruby:

```ruby
doctype!
html do
  head do
    link :rel => 'stylesheet', :href => 'style.css'
    script :src => 'jquery.js'
  end
  body :id => :frontpage do
    h1 'Hello World', :class => :main
  end
end
```


Syntax
------

### 1. Tags and Attributes

There are four basic forms:

```ruby
tagname(content)

tagname(content, attributes)

tagname do
  content
end

tagname(attributes) do
  content
end
```

Example:

```ruby
doctype!
html do
  head do
    link :rel => 'stylesheet', :href => 'style.css'
    script :src => 'jquery.js'
  end
  body :id => :frontpage do
    h1 'Hello World', :class => :main
  end
end
```

Which results in:

```html
<!DOCTYPE html>
<html>
  <head>
    <link rel="stylesheet" href="style.css">
    <script src="jquery"></script>
  </head>
  <body id="frontpage">
    <h1 class="main">Hello World</h1>
  </body>
</html>
```

Notice how Mab knows that script tag must have content, so although you didn't
specify anything it closed the tag for you.

### 2. Element Classes and IDs

You can easily add classes and IDs by hooking methods onto the container:

```ruby
body.frontpage! do
  h1.main 'Hello World'
end
```

Which results in:

```html
<body id="frontpage">
  <h1 class="main">Hello World</h1>
</body>
```

You can mix and match as you'd like (`div.klass.klass1.id!`), but you can only
provide content and attributes on the *last* call:

```ruby
# This is not valid:
form(:action => :post).world do
  input
end

# But this is:
form.world(:action => :post) do
  input
end
```

### 3. Escape or Not Escape

Mab uses a very simple convention for escaping: Strings as *arguments* gets
escaped, strings in *blocks* don't:

```ruby
div.comment "<script>alert(1)</script>"
# <div class="comment">&lt;script&gt;alert(1)&lt;/script&gt;</div>

div.comment { "I <strong>love</strong> you" }
# <div class="comment">I <strong>love</strong> you</div>
```

Be aware that Mab ignores the string in a block if there's other tags there:

```ruby
div.comment do
  div.author "BitPuffin"
  "<p>Silence!</p>"
end
```

The p tag above won't appear in the output.

### 4. Text

Sometimes you need to insert plain text:

```ruby
p.author do
  text 'Written by '
  a 'Bluebie', :href => 'http://creativepony.com/'
end
```

Which results in:

```html
<p class="author">
  Written by
  <a href="http://creativepony.com/">Bluebie</a>
</p>
```

There's also `text!` which doesn't escape:

```ruby
p.author do
  text! '<strong>Written</strong> by'
  a 'Bluebie', :href => 'http://creativepony.com/'
```


Invoking Mab
------------

Using #mab:

```ruby
require 'mab/kernel_method'

str = mab do
  doctype!
  html do
    # ...
  end
end
```

Using Mab::Builder (or Mab::PrettyBuilder if you want indentation):

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
end.to_s
```

Extending an object (*advanced usage*):

```ruby
r = Object.new
r.extend Mab::Mixin::HTML5
r.extend Mab::Indentation

r.mab do
  doctype!
  html do
    # ...
  end
end

```


