// DEFINE HASH MAP CLASS
class HashMap {
  constructor(initialCapacity = 16, loadFactor = 0.75) {
    this.buckets = new Array(initialCapacity);
    this.size = 0;
    this.loadFactor = loadFactor;
  }

  // DEFINE HASH FUNCTION
  hash(key) {
    let hashCode = 0;
    const primeNumber = 31;
    for (let i = 0; i < key.length; i++) {
      hashCode = (primeNumber * hashCode + key.charCodeAt(i)) % this.buckets.length;
    }
    return hashCode;
  }

  // SET KEY-VALUE PAIR
  set(key, value) {
    const index = this.hash(key);
    if (index < 0 || index >= this.buckets.length) {
      throw new Error("Trying to access index out of bound");
    }

    if (!this.buckets[index]) {
      this.buckets[index] = [];
    }

    for (let i = 0; i < this.buckets[index].length; i++) {
      if (this.buckets[index][i][0] === key) {
        this.buckets[index][i][1] = value;
        return;
      }
    }

    this.buckets[index].push([key, value]);
    this.size++;

    if (this.size > this.buckets.length * this.loadFactor) {
      this.grow();
    }
  }

  // GET VALUE BY KEY
  get(key) {
    const index = this.hash(key);
    if (this.buckets[index]) {
      for (let i = 0; i < this.buckets[index].length; i++) {
        if (this.buckets[index][i][0] === key) {
          return this.buckets[index][i][1];
        }
      }
    }
    return null;
  }

  // CHECK IF KEY EXISTS
  has(key) {
    const index = this.hash(key);
    if (this.buckets[index]) {
      for (let i = 0; i < this.buckets[index].length; i++) {
        if (this.buckets[index][i][0] === key) {
          return true;
        }
      }
    }
    return false;
  }

  // REMOVE KEY-VALUE PAIR
  remove(key) {
    const index = this.hash(key);
    if (this.buckets[index]) {
      for (let i = 0; i < this.buckets[index].length; i++) {
        if (this.buckets[index][i][0] === key) {
          this.buckets[index].splice(i, 1);
          this.size--;
          return true;
        }
      }
    }
    return false;
  }

  // GET LENGTH OF HASH MAP
  length() {
    return this.size;
  }

  // CLEAR HASH MAP
  clear() {
    this.buckets = new Array(this.buckets.length);
    this.size = 0;
  }

  // GET KEYS
  keys() {
    const keysArray = [];
    for (let i = 0; i < this.buckets.length; i++) {
      if (this.buckets[i]) {
        for (let j = 0; j < this.buckets[i].length; j++) {
          keysArray.push(this.buckets[i][j][0]);
        }
      }
    }
    return keysArray;
  }

  // GET VALUES
  values() {
    const valuesArray = [];
    for (let i = 0; i < this.buckets.length; i++) {
      if (this.buckets[i]) {
        for (let j = 0; j < this.buckets[i].length; j++) {
          valuesArray.push(this.buckets[i][j][1]);
        }
      }
    }
    return valuesArray;
  }

  // GET ENTRIES
  entries() {
    const entriesArray = [];
    for (let i = 0; i < this.buckets.length; i++) {
      if (this.buckets[i]) {
        for (let j = 0; j < this.buckets[i].length; j++) {
          entriesArray.push([this.buckets[i][j][0], this.buckets[i][j][1]]);
        }
      }
    }
    return entriesArray;
  }

  // RESIZE BUCKETS WHEN LOAD FACTOR IS REACHED
  grow() {
    const newCapacity = this.buckets.length * 2;
    const newBuckets = new Array(newCapacity);
    for (let i = 0; i < this.buckets.length; i++) {
      if (this.buckets[i]) {
        for (let j = 0; j < this.buckets[i].length; j++) {
          const [key, value] = this.buckets[i][j];
          const newIndex = this.hash(key);
          if (!newBuckets[newIndex]) {
            newBuckets[newIndex] = [];
          }
          newBuckets[newIndex].push([key, value]);
        }
      }
    }
    this.buckets = newBuckets;
  }
}

// CREATE HASH MAP INSTANCE
const map = new HashMap();
map.set("key1", "value1");
map.set("key2", "value2");
console.log(map.get("key1")); // Output: value1
console.log(map.has("key2")); // Output: true
map.remove("key2");
console.log(map.keys()); // Output: ['key1']
console.log(map.values()); // Output: ['value1']
console.log(map.entries()); // Output: [['key1', 'value1']]
console.log(map.length()); // Output: 1
map.clear();
console.log(map.length()); // Output: 0
