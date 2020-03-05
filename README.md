# module-cache

Fast and performante cache for javascript modules

Deleting a module from "require.cache" is a good idea when dealing with development mode. In production, doing so will decrease performance. 
Several times we need to load temporary modules to memory (JSON, js-files) and retrieve theme when finish.
This module will help you to do so. 
The module support LRU (Least Recently Used) and TTL (Time To Live) to remove modules automatically.

Works on NodeJS version >= 12.

## Why to use:

- Fast: Do not use "require" to load modules
- Temporary load modules to memory without using the slow "require"
- Load JSON files and JavaScipt files
- Uses LRU and TTL to auto remove modules as needed
- Uses cache based on memory size (Do not evaluate dynamic size evolution)
- Performance maintained regardless adding and removing modules

## Precautions
- DO NOT USE THIS MODULE TO LOAD UNTRUSTED MODULES!
- Do not permanetly reference any object or part of object loaded via the cache. Doing so will result that the object will maintain in the memory!
- Not recommended to use this to load libraries. Libraries should be maintained in memory for performance optimization.

## Use cases
- This module is used by "GridFw" to load temporary i18n data and views to memory.

## Usage
```javascript
const ModuleCache= require('module-cache');

const cache= new ModuleCache(); // or new ModuleCache({options});
/**
 * Could export this var, so we can use the same cache 
 * in the whole application
 * or setting it as Global variable
 */
module.exports= cache;


// Add/get module: Just add the absolute or relative path to that file
var mod= await cache.require('/path/to/file.js'); // load and execute JS file
var data= await cache.require('/path/to/file.json'); // load JSON file
var mod2= await cache.get('/path/to/file'); // alternative to require

var mod3= cache.requireSync('/path/to/file'); // Synchrounous require
var mod4= cache.getSync('/path/to/file'); // alternative

// remove module from the cache
cache.delete('/path/to/file.js');	// remove the JS file
cache.delete('/path/to/file.json');	// remove the JSON file

// Check if a file is loaded
<Boolean> cache.has('/path/to/file');

// Get the size of the cache
var entriesCount= cache.size;

// Get estimated cache size in bytes
var bytes= cache.bytes

// Remove all modules
cache.clear();

// Remove least used module
var mod= cache.pop();

// Get all current kies
<Iterator(key)> cache.keys();

// Get all loaded modules
<Iterator(value)> cache.values();

// Get all entries
<Iterator([key, value])> cache.entries();

// ForEach
cache.forEach(function callback(value, key){});

// Change cache configuration
cache.setConfiguration(options);
```

## Options
```javascript
const options= {
	/**
	 * Set the maximum entries in the cache for the LRU algorithm
	 * remove the least used element when this is exceeded
	 * @default  Infinity
	 */
	max: Infinity,
	/**
	 * Set the TTL (ms) of each element
	 * Removes the element if the ttl is exceeded
	 * The TTL is reset when getting ( via cache.get )
	 * or updating an element ( via cache.set )
	 * @default Infinity
	 */
	ttl: Infinity,
	/**
	 * Set the element as the last used when calling the cache.get method
	 * @default true
	 */
	refreshOnGet: true,
	/**
	 * Maximum cache size in bytes
	 * to use this, you need to add the size of each entry
	 * via catch.set(key, value, bytes)
	 * @type {Number}
	 */
	maxBytes: Infinity
	/**
	 * Module execution timeout
	 * This means timeout for the module to be loaded, executed
	 * and returns the exported value
	 * @default  60s
	 */
	timeout: 60000
};
```


# Credits

Khalid RAFIK

# Let's contribute
Open an issue or contact me: khalid.rfk@gmail.com

# Support
Open an issue or contact me: khalid.rfk@gmail.com

# Licence

MIT License

Copyright (c) 2020 rafikalid

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
