class HashMap
  def initialize
    @buckets = Array.new(16)
    @size = 0
    @load_factor = 0.75
  end

  # DEFINE HASH FUNCTION
  def hash(key)
    hash_code = 0
    prime_number = 31

    key.each_char { |char| hash_code = prime_number * hash_code + char.ord }

    hash_code
  end

  # SET KEY-VALUE PAIR
  def set(key, value)
    index = hash(key) % @buckets.length
    @buckets[index] ||= []

    @buckets[index].each_with_index do |pair, i|
      if pair[0] == key
        @buckets[index][i][1] = value
        return
      end
    end

    @buckets[index] << [key, value]
    @size += 1
    resize if @size >= @load_factor * @buckets.length
  end

  # GET VALUE BY KEY
  def get(key)
    index = hash(key) % @buckets.length
    return nil unless @buckets[index]

    @buckets[index].each do |pair|
      return pair[1] if pair[0] == key
    end
    nil
  end

  # CHECK IF KEY EXISTS
  def has(key)
    index = hash(key) % @buckets.length
    return false unless @buckets[index]

    @buckets[index].each do |pair|
      return true if pair[0] == key
    end
    false
  end

  # REMOVE KEY-VALUE PAIR
  def remove(key)
    index = hash(key) % @buckets.length
    return nil unless @buckets[index]

    @buckets[index].each_with_index do |pair, i|
      if pair[0] == key
        @size -= 1
        return @buckets[index].delete_at(i)[1]
      end
    end
    nil
  end

  # GET LENGTH OF HASH MAP
  def length
    @size
  end

  # CLEAR HASH MAP
  def clear
    @buckets = Array.new(16)
    @size = 0
  end

  # GET KEYS
  def keys
    result = []
    @buckets.each do |bucket|
      next unless bucket

      bucket.each do |pair|
        result << pair[0]
      end
    end
    result
  end

  # GET VALUES
  def values
    result = []
    @buckets.each do |bucket|
      next unless bucket

      bucket.each do |pair|
        result << pair[1]
      end
    end
    result
  end

  # GET ENTRIES
  def entries
    result = []
    @buckets.each do |bucket|
      next unless bucket

      bucket.each do |pair|
        result << pair
      end
    end
    result
  end

  private

  # RESIZE BUCKETS WHEN LOAD FACTOR IS REACHED
  def resize
    new_buckets = Array.new(@buckets.length * 2)
    @buckets.each do |bucket|
      next unless bucket

      bucket.each do |pair|
        index = hash(pair[0]) % new_buckets.length
        new_buckets[index] ||= []
        new_buckets[index] << pair
      end
    end
    @buckets = new_buckets
  end
end

# CREATE HASH MAP INSTANCE
hash_map = HashMap.new

# SET KEY-VALUE PAIR
hash_map.set("key1", "value1")
puts hash_map.entries.inspect

# GET VALUE BY KEY
puts hash_map.get("key1")

# CHECK IF KEY EXISTS
puts hash_map.has("key1")

# REMOVE KEY-VALUE PAIR
puts hash_map.remove("key1")

# GET LENGTH OF HASH MAP
puts hash_map.length

# CLEAR HASH MAP
hash_map.clear

# GET KEYS
puts hash_map.keys.inspect

# GET VALUES
puts hash_map.values.inspect

# GET ENTRIES
puts hash_map.entries.inspect
