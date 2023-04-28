require "yaml"

class A
  def initialize(string, number)
    @string = string
    @number = number
  end

  def to_s
    "In A:\n   #{@string}, #{@number}\n"
  end
end

class B
  def initialize(number, a_object)
    @number = number
    @a_object = a_object
  end

  def to_s
    "In B: #{@number} \n  #{@a_object.to_s}\n"
  end
end

class C
  def initialize(b_object, a_object)
    @b_object = b_object
    @a_object = a_object
  end

  def to_s
    "In C:\n #{@a_object} #{@b_object}\n"
  end
end

a = A.new("hello world", 5)
b = B.new(7, a)
c = C.new(b, a)


=begin
Since we created a to_s, method, we can see the string representation of our object tree:

<pre>In C:
 In A:
   hello world, 5
 In B: 7
  In A:
   hello world, 5</pre>

To serialize our object tree we simply do the following:

```ruby
serialized_object = YAML::dump(c)
puts serialized_object```

Our serialized object looks like this:

<pre>--- !ruby/object:C
a_object: &id001 !ruby/object:A
  number: 5
  string: hello world
b_object: !ruby/object:B
  a_object: *id001
  number: 7</pre>

If we now want to get it back:

```ruby
puts YAML::load(serialized_object)```

This produces output which is exactly the same as what we had above, which means our object tree was reproduced correctly:

<pre>In C:
 In A:
   hello world, 5
 In B: 7
  In A:
   hello world, 5</pre>

Of course **you almost never want to serialize just one object**, it is usually an array or a hash. In this case you have two options, either you serialize the whole array/hash in one go, or you serialize each value separately. The rule here is simple, if you always need to work with the whole set of data and never parts of it, just write out the whole array/hash, otherwise, iterate over it and write out each object. The reason you do this is almost always to share the data with someone else.

If you just write out the whole array/hash in one fell swoop then it is as simple as what we did above. When you do it one object at a time, it is a little more complicated, since we don't want to write it out to a whole bunch of files, but rather all of them to one file. It is a little more complicated since you want to be able to easily read your objects back in again which can be tricky as <span style="font-style: italic;"></span>_YAML_ serialization creates multiple lines per object. Here is a trick you can use, when you write the objects out, separate them with two newlines e.g.:

```ruby
File.open("/home/alan/tmp/blah.yaml", "w") do |file|
  (1..10).each do |index|
    file.puts YAML::dump(A.new("hello world", index))
    file.puts ""
  end
end```

The file will look like this:

<pre>--- !ruby/object:A
number: 1
string: hello world

--- !ruby/object:A
number: 2
string: hello world

...</pre>

Then when you want to read all the objects back, simply set the input record separator to be two newlines e.g.:

```ruby
array = []
$/="\n\n"
File.open("/home/alan/tmp/blah.yaml", "r").each do |object|
  array &lt;&lt; YAML::load(object)
end

puts array```

The output is:

<pre>In A:
   hello world, 1
In A:
   hello world, 2
In A:
   hello world, 3
...</pre>

Which is exactly what we expect &#8211; handy. By the way, I will be covering things like the input record separator in an upcoming series of posts I am planning to do about Ruby one-liners, so don't forget to subscribe if you don't want to miss it.

## A 3rd Party Alternative

Of course, if we don't want to resort to tricks like that, but still keep our serialized objects human-readable, we have another alternative which is basically as common as the Ruby built in serialization methods &#8211; <a href="http://www.json.org/" target="_blank">JSON</a>. The JSON support in Ruby is <a href="http://flori.github.com/json/" target="_blank">provided by a 3rd party library</a>, all you need to do is:

<pre>gem install json</pre>

or

<pre>gem install json-pure</pre>

The second one is if you want a pure Ruby implementation (_no native extensions_).

**The good thing about JSON, is the fact that it is even more human readable than YAML**. It is also a "_low-fat_" alternative to XML and can be used to transport data over the wire by AJAX calls that require data from the server (_that's the simple one sentence explanation :)_). The other good news when it comes to serializing objects to JSON using Ruby is that if you save the object to a file, it saves it on one line, so we don't have to resort to tricks when saving multiple objects and reading them back again.&nbsp;

There is bad news of course, in that your objects won't automagically be converted to JSON, unless all you're using is hashes, arrays and primitives. You need to do a little bit of work to make sure your custom object is serializable. Let&rsquo;s make one of the classes we introduced previously serializable using JSON.
=end

require "json"

class A
  def initialize(string, number)
    @string = string
    @number = number
  end

  def to_s
    "In A:\n   #{@string}, #{@number}\n"
  end

  def to_json(*a)
    {
      "json_class"   =&gt; self.class.name,
      "data"         =&gt; {"string" =&gt; @string, "number" =&gt; @number }
    }.to_json(*a)
  end

  def self.json_create(o)
    new(o["data"]["string"], o["data"]["number"])
  end
end

=begin
Make sure to not forget to '_require_' json, otherwise you'll get funny behaviour. Now you can simply do the following:

a = A.new("hello world", 5)
json_string = a.to_json
puts json_string
puts JSON.parse(json_string)```

Which produces output like this:

<pre>{"json_class":"A","data":{"string":"hello world","number":5}}
In A:
   hello world, 5</pre>

The first string is our serialized JSON string, and the second is the result of outputting our deserialized object, which gives the output that we expect.

As you can see, we implement two methods:

  * _**to_json**_ &#8211; called on the object instance and allows us to convert an object into a JSON string.
  * _**json_create**_ &#8211; allows us to call _JSON.parse_ passing in a JSON string which will convert the string into an instance of our object

You can also see that, when converting our object into a JSON string we need to make sure, that we end up with a hash and that contains the '_json_class_' key. We also need to make sure that we only use hashes, arrays, primitives (_i.e. integers, floats etc., not really primitives in Ruby but you get the picture_) and strings.

So, JSON has some advantages and some disadvantages. I like it because it is widely supported so you can send data around and have it be recognised by other apps. I don't like it because you need to do work to make sure your objects are easily serializable, so if you don't need to send your data anywhere but simply want to share it locally, it is a bit of a pain.

## Binary Serialization

<p style="text-align: center;">
  <img align="middle" alt="Binary" class="aligncenter size-full wp-image-1696" height="196" src="http://www.skorks.com/wp-content/uploads/2010/04/binary.jpg" style="width: 295px; height: 196px;" title="Binary" vspace="3" width="295" srcset="https://www.skorks.com/wp-content/uploads/2010/04/binary.jpg 500w, https://www.skorks.com/wp-content/uploads/2010/04/binary-300x199.jpg 300w" sizes="(max-width: 295px) 100vw, 295px" />
</p>

The other serialization mechanism built into Ruby is binary serialization using <a href="http://ruby-doc.org/core/classes/Marshal.html" target="_blank"><em>Marshal</em></a>. **It is very similar to _YAML_ and just as easy to use, the only difference is it's not human readable as it stores your objects in a binary format**. You use Marshal exactly the same way you use YAML, but replace the word YAML with Marshal :)

```ruby
a = A.new("hello world", 5)
puts a
serialized_object = Marshal::dump(a)
puts Marshal::load(serialized_object)
In A:
   hello world, 5
In A:
   hello world, 5
As you can see, according to the output the objects before and after serialization are the same. You don’t even need to require anything :). The thing to watch out for when outputting multiple Marshalled objects to the same file, is the record separator. Since you’re writing binary data, it is not inconceivable that you may end up with a newline somewhere in a record accidentally, which will stuff everything up when you try to read the objects back in. So two rules of thumb to remember are:

don’t use puts when outputting Marshalled objects to a file (use print instead), this way you avoid the extraneous newline from the puts
use a record separator other than newline, you can make anything unlikely up (if you scroll down a bit you will see that I used ‘——’ as a separator_)
The disadvantage of Marshal is the fact the its output it not human-readable. The advantage is its speed.

Which One To Choose?
It’s simple, if you need to be able to read your serializable data then you have to go with one of the human-readable formats (YAML or JSON). I’d go with YAML purely because you don’t need to do any work to get your custom objects to serialize properly, and the fact that it serializes each object as a multiline string is not such a big deal (as I showed above). The only times I would go with JSON (aside the whole wide support and sending it over the wire deal), is if you need to be able to easily edit your data by hand, or when you need human-readable data and you have a lot of data to deal with (_see benchmarks below_).

If you don’t really need to be able to read your data, then always go with Marshal, especially if you have a lot of data.

Here is a situation I commonly have to deal with. I have a CSV file, or some other kind of data file, I want to read it, parse it and create an object per row or at least a hash per row, to make the data easier to deal with. What I like to do is read this CSV file, create my object and serialize them to a file at the same time using Marshal. This way I can operate on the whole data set or parts of the data set, by simply reading the serialized objects in, and it is orders of magnitude faster than reading the CSV file again. Let’s do some benchmarks. I will create 500000 objects (a relatively small set of data) and serialize them all to a file using all three methods.
=end

require "benchmark"

def benchmark_serialize(output_file)
  Benchmark.realtime do
    File.open(output_file, "w") do |file|
      (1..500000).each do |index|
        yield(file, A.new("hello world", index))
      end
    end
  end
end

puts "YAML:"
time = benchmark_serialize("/home/alan/tmp/yaml.dat") do |file, object|
  file.puts YAML::dump(object)
  file.puts ""
end
puts "Time: #{time} sec"

puts "JSON:"
time = benchmark_serialize("/home/alan/tmp/json.dat") do |file, object|
  file.puts object.to_json
end
puts "Time: #{time} sec"

puts "Marshal:"
time = benchmark_serialize("/home/alan/tmp/marshal.dat") do |file, object|
  file.print Marshal::dump(object)
  file.print "---_---"
end
puts "Time: #{time} sec"


YAML:
Time: 45.9780583381653 sec
JSON:
Time: 5.44697618484497 sec
Marshal:
Time: 2.77714705467224 sec


# What about deserializing all the objects:

def benchmark_deserialize(input_file, array, input_separator)
  $/=input_separator
  Benchmark.realtime do
    File.open(input_file, "r").each do |object|
      array &lt;&lt; yield(object)
    end
  end
end

array1 = []
puts "YAML:"
time = benchmark_deserialize("/home/alan/tmp/yaml.dat", array1, "\n\n") do |object|
  YAML::load(object)
end
puts "Array size: #{array1.length}"
puts "Time: #{time} sec"

array2 = []
puts "JSON:"
time = benchmark_deserialize("/home/alan/tmp/json.dat", array2, "\n") do |object|
  JSON.parse(object)
end
puts "Array size: #{array2.length}"
puts "Time: #{time} sec"

array3 = []
puts "Marshal:"
time = benchmark_deserialize("/home/alan/tmp/marshal.dat", array3, "---_---") do |object|
  Marshal::load(object.chomp)
end
puts "Array size: #{array3.length}"
puts "Time: #{time} sec"

=begin

YAML:
Array size: 500000
Time: 19.4334170818329 sec
JSON:
Array size: 500000
Time: 18.5326402187347 sec
Marshal:
Array size: 500000
Time: 14.6655268669128 sec
As you can see, it is significantly faster to serialize objects when you’re using Marshal, although JSON is only about 2 times slower. YAML gets left in the dust. When deserializing, the differences are not as apparent, although Marshal is still the clear winner. The more data you have to deal with the more telling these results will be. So, for pure speed – choose Marshal. For speed and human readability – choose JSON (at the expense of having to add methods to custom objects). For human readability with relatively small sets of data – go with YAML.

That’s pretty much all you need to know, but it is not all I have to say on serialization. One of the more interesting (and cool) features of Ruby is how useful blocks can be in many situations, so you will inevitably, eventually run into a situation where you may want to serialize a block and this is where you will find trouble! We will deal with block serialization issues and what (if anything) you can do about it in a subsequent post. More Ruby soon :).

Images by Andrew Mason and just.Luc

coding ruby serialization
 On The Mastery Of TeachingWhy Aren’t You Awesome Yet? (Learning Via The World-Wide Community) 
Show Disqus Comments
© 2008 - 2018  Alan Skorkin
=end