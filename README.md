**Project: HashMap Implementation**

This repository contains implementations of a HashMap data structure in both JavaScript and Ruby.

### JavaScript Implementation (HashMap.js)

#### Introduction
The JavaScript implementation provides a HashMap class that allows you to store key-value pairs efficiently.

#### Usage
1. **Set up HashMap:** Create a new instance of the HashMap class.
   ```javascript
   const map = new HashMap();
   ```

2. **Set Key-Value Pair:** Use the `set(key, value)` method to add a new key-value pair to the HashMap.
   ```javascript
   map.set("key1", "value1");
   ```

3. **Get Value:** Use the `get(key)` method to retrieve the value associated with a key.
   ```javascript
   const value = map.get("key1");
   console.log(value); // Output: value1
   ```

4. **Check Key Existence:** Use the `has(key)` method to check if a key exists in the HashMap.
   ```javascript
   console.log(map.has("key2")); // Output: true
   ```

5. **Remove Key-Value Pair:** Use the `remove(key)` method to remove a key-value pair from the HashMap.
   ```javascript
   map.remove("key2");
   ```

6. **Get Keys, Values, and Entries:** Use the `keys()`, `values()`, and `entries()` methods to retrieve keys, values, and key-value pairs respectively.
   ```javascript
   console.log(map.keys()); // Output: ['key1']
   console.log(map.values()); // Output: ['value1']
   console.log(map.entries()); // Output: [['key1', 'value1']]
   ```

7. **Get Length:** Use the `length()` method to get the number of stored keys in the HashMap.
   ```javascript
   console.log(map.length()); // Output: 1
   ```

8. **Clear HashMap:** Use the `clear()` method to remove all entries from the HashMap.
   ```javascript
   map.clear();
   ```

#### Installation
No specific installation steps are required. Simply include the `HashMap.js` file in your project and instantiate the HashMap class as needed.

### Ruby Implementation (hashmap.rb)

#### Introduction
The Ruby implementation provides a HashMap class that allows you to store key-value pairs efficiently.

#### Usage
1. **Set up HashMap:** Create a new instance of the HashMap class.
   ```ruby
   map = HashMap.new
   ```

2. **Set Key-Value Pair:** Use the `set(key, value)` method to add a new key-value pair to the HashMap.
   ```ruby
   map.set("key1", "value1")
   ```

3. **Get Value:** Use the `get(key)` method to retrieve the value associated with a key.
   ```ruby
   value = map.get("key1")
   puts value # Output: value1
   ```

4. **Check Key Existence:** Use the `has(key)` method to check if a key exists in the HashMap.
   ```ruby
   puts map.has("key2") # Output: true
   ```

5. **Remove Key-Value Pair:** Use the `remove(key)` method to remove a key-value pair from the HashMap.
   ```ruby
   map.remove("key2")
   ```

6. **Get Length:** Use the `length()` method to get the number of stored keys in the HashMap.
   ```ruby
   puts map.length # Output: 1
   ```

7. **Clear HashMap:** Use the `clear()` method to remove all entries from the HashMap.
   ```ruby
   map.clear
   ```

#### Installation
No specific installation steps are required. Simply include the `hashmap.rb` file in your project and instantiate the HashMap class as needed.

### Conclusion
These HashMap implementations provide efficient ways to store and retrieve key-value pairs in your JavaScript and Ruby projects. Whether you're working in JavaScript or Ruby, you can utilize the HashMap class to manage your data effectively.