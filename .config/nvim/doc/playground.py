"""
Python Playground for Neovim
Select any code block and press <leader>px to execute it
Or place cursor on a line and press <leader>px to run just that line
"""

# =============================================================================
# BASIC PYTHON SYNTAX
# =============================================================================

# Lists (like Lua tables/arrays)
plugins = ["lazy.nvim", "snacks.nvim", "telescope.nvim"]
print("Plugins:", plugins)
print("First plugin:", plugins[0])  # Python arrays are 0-indexed!

# Dictionaries (like Lua tables)
config = {
    "editor": "Neovim",
    "version": 0.10,
    "plugins": plugins,
}

print("Config:", config)
print("Editor:", config["editor"])

# Functions
def greet(name):
    return f"Hello, {name}!"

print(greet("World"))

# Lambda functions
square = lambda x: x * x
print(f"5 squared is {square(5)}")

# Conditionals
from datetime import datetime

hour = datetime.now().hour

if hour < 12:
    print("Good morning!")
elif hour < 18:
    print("Good afternoon!")
else:
    print("Good evening!")

# Loops
print("Counting to 5:")
for i in range(1, 6):
    print(i)

print("\nIterating over plugins:")
for i, plugin in enumerate(plugins, start=1):
    print(i, plugin)

print("\nIterating over key-value pairs:")
for key, value in config.items():
    print(f"{key} = {value}")

# List comprehensions
evens = [n for n in range(1, 11) if n % 2 == 0]
print("Even numbers:", evens)

doubled = [n * 2 for n in range(1, 11)]
print("Doubled:", doubled)

# =============================================================================
# FILE SYSTEM OPERATIONS
# =============================================================================

import os
from pathlib import Path

# Current working directory
cwd = os.getcwd()
print("Current working directory:", cwd)

# Path operations
home = Path.home()
print("Home directory:", home)

# Check if file/directory exists
print("Home exists:", home.exists())
print("Non-existent file:", Path("/this/does/not/exist").exists())

# List files in directory
print("\nFiles in current directory:")
for i, item in enumerate(Path.cwd().iterdir(), start=1):
    if i <= 10:  # Show first 10
        print(f"{i}. {item.name} {'(dir)' if item.is_dir() else '(file)'}")

# File path operations
filepath = Path("/home/user/config/init.lua")
print("\nPath operations:")
print("Parent:", filepath.parent)
print("Name:", filepath.name)
print("Stem:", filepath.stem)
print("Suffix:", filepath.suffix)

# =============================================================================
# STRING OPERATIONS
# =============================================================================

# String manipulation
text = "  Hello, Neovim!  "
print("Original:", repr(text))
print("Stripped:", repr(text.strip()))
print("Upper:", text.upper())
print("Lower:", text.lower())
print("Length:", len(text))

# String splitting
csv = "apple,banana,cherry"
fruits = csv.split(',')
print("Fruits:", fruits)

# String joining
print("Joined:", ' - '.join(fruits))

# String formatting
formatted = f"{name} version {version}"
print(formatted)

# String methods
sentence = "the quick brown fox"
print("Capitalized:", sentence.capitalize())
print("Title case:", sentence.title())
print("Replace:", sentence.replace("fox", "dog"))
print("Split:", sentence.split())

# =============================================================================
# DATA STRUCTURES
# =============================================================================

# Lists
numbers = [1, 2, 3, 4, 5]
numbers.append(6)
numbers.extend([7, 8, 9])
print("Numbers:", numbers)
print("First 3:", numbers[:3])
print("Last 3:", numbers[-3:])
print("Reversed:", numbers[::-1])

# Sets
unique = {1, 2, 2, 3, 3, 3}
print("Set:", unique)
unique.add(4)
print("After add:", unique)

# Tuples (immutable)
coords = (10, 20)
x, y = coords  # Unpacking
print(f"Coordinates: x={x}, y={y}")

# Dictionary operations
person = {"name": "Alice", "age": 30}
person["city"] = "NYC"
print("Person:", person)
print("Keys:", list(person.keys()))
print("Values:", list(person.values()))
print("Get with default:", person.get("email", "N/A"))

# =============================================================================
# WORKING WITH CLASSES
# =============================================================================

class Buffer:
    """Represents a Neovim buffer"""

    def __init__(self, number, name):
        self.number = number
        self.name = name
        self.modified = False

    def __str__(self):
        status = "modified" if self.modified else "unmodified"
        return f"Buffer({self.number}, {self.name}, {status})"

    def mark_modified(self):
        self.modified = True

# Create instances
buf1 = Buffer(1, "init.lua")
buf2 = Buffer(2, "plugins.lua")
buf2.mark_modified()

print(buf1)
print(buf2)

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Try-except
try:
    result = 10 / 2
    print(f"Division result: {result}")
except ZeroDivisionError:
    print("Cannot divide by zero!")
except Exception as e:
    print(f"An error occurred: {e}")
else:
    print("No errors occurred")
finally:
    print("This always executes")

# =============================================================================
# FUNCTIONAL PROGRAMMING
# =============================================================================

# Map, filter, reduce
nums = [1, 2, 3, 4, 5]

# Map
squared = list(map(lambda x: x ** 2, nums))
print("Squared:", squared)

# Filter
evens = list(filter(lambda x: x % 2 == 0, nums))
print("Evens:", evens)

# Reduce
from functools import reduce

sum_all = reduce(lambda a, b: a + b, nums)
print("Sum:", sum_all)

# Any and all
print("Any even?", any(n % 2 == 0 for n in nums))
print("All positive?", all(n > 0 for n in nums))

# =============================================================================
# ITERATORS AND GENERATORS
# =============================================================================

# Generator function
def countdown(n):
    """Generator that counts down from n to 1"""
    while n > 0:
        yield n
        n -= 1

print("Countdown:")
for i in countdown(5):
    print(i)

# Generator expression
squares = (x ** 2 for x in range(5))
print("Squares:", list(squares))

# =============================================================================
# WORKING WITH JSON
# =============================================================================

import json

# Python dict to JSON
data = {
    "name": "Neovim",
    "version": "0.10",
    "plugins": ["lazy.nvim", "snacks.nvim"]
}

json_string = json.dumps(data, indent=2)
print("JSON:\n", json_string)

# JSON to Python dict
parsed = json.loads(json_string)
print("Parsed:", parsed)

# =============================================================================
# DATE AND TIME
# =============================================================================

from datetime import datetime, timedelta

# Current date and time
now = datetime.now()
print("Current time:", now)
print("Formatted:", now.strftime("%Y-%m-%d %H:%M:%S"))

# Date arithmetic
tomorrow = now + timedelta(days=1)
print("Tomorrow:", tomorrow.strftime("%Y-%m-%d"))

# Time components
print(f"Year: {now.year}, Month: {now.month}, Day: {now.day}")
print(f"Hour: {now.hour}, Minute: {now.minute}")

# =============================================================================
# REGULAR EXPRESSIONS
# =============================================================================

import re

# Pattern matching
text = "My email is user@example.com and phone is 555-1234"
email_pattern = r'[\w\.-]+@[\w\.-]+'
phone_pattern = r'\d{3}-\d{4}'

email = re.search(email_pattern, text)
phone = re.search(phone_pattern, text)

if email:
    print("Email found:", email.group())
if phone:
    print("Phone found:", phone.group())

# Find all matches
numbers = re.findall(r'\d+', text)
print("All numbers:", numbers)

# Replace
cleaned = re.sub(r'\d', 'X', text)
print("Replaced:", cleaned)

# =============================================================================
# COLLECTIONS MODULE
# =============================================================================

from collections import Counter, defaultdict, namedtuple

# Counter
words = ["apple", "banana", "apple", "cherry", "banana", "apple"]
word_count = Counter(words)
print("Word count:", word_count)
print("Most common:", word_count.most_common(2))

# defaultdict
word_indices = defaultdict(list)
for i, word in enumerate(words):
    word_indices[word].append(i)
print("Word indices:", dict(word_indices))

# namedtuple
Point = namedtuple('Point', ['x', 'y'])
p = Point(10, 20)
print(f"Point: x={p.x}, y={p.y}")

# =============================================================================
# PRACTICAL EXAMPLES
# =============================================================================

# Example 1: Read and process a file
def count_lines_and_words(filepath):
    """Count lines and words in a file"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            line_count = len(lines)
            word_count = sum(len(line.split()) for line in lines)
            print(f"Lines: {line_count}, Words: {word_count}")
            return line_count, word_count
    except FileNotFoundError:
        print(f"File not found: {filepath}")
        return 0, 0

# Uncomment to try with an actual file:
# count_lines_and_words(__file__)

# Example 2: Simple data analysis
def analyze_numbers(nums):
    """Calculate statistics for a list of numbers"""
    if not nums:
        return None

    stats = {
        "count": len(nums),
        "sum": sum(nums),
        "mean": sum(nums) / len(nums),
        "min": min(nums),
        "max": max(nums),
    }
    print("Statistics:", stats)
    return stats

data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
analyze_numbers(data)

# Example 3: Group items by property
def group_by_length(words):
    """Group words by their length"""
    groups = defaultdict(list)
    for word in words:
        groups[len(word)].append(word)

    print("Grouped by length:")
    for length, word_list in sorted(groups.items()):
        print(f"  {length}: {word_list}")

    return dict(groups)

words_list = ["a", "to", "the", "an", "cat", "dog", "bird", "fish"]
group_by_length(words_list)

# Example 4: Decorator pattern
def timer(func):
    """Decorator to time function execution"""
    import time
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {(end - start) * 1000:.2f}ms")
        return result
    return wrapper

@timer
def slow_function():
    """A function that takes some time"""
    import time
    time.sleep(0.1)
    return "Done!"

# Uncomment to try:
# slow_function()

# Example 5: Context manager
class Timer:
    """Context manager for timing code blocks"""
    def __enter__(self):
        import time
        self.start = time.time()
        return self

    def __exit__(self, *args):
        import time
        self.end = time.time()
        print(f"Elapsed: {(self.end - self.start) * 1000:.2f}ms")

# Uncomment to try:
# with Timer():
#     sum(range(1000000))

# =============================================================================
# TIPS
# =============================================================================

"""
TIPS FOR USING THIS PLAYGROUND:

1. Execute any code:
   - Visual select and press <leader>px
   - Or press <leader>px on a single line

2. Check results:
   - Output appears in :messages
   - Or check the terminal if running Python scripts

3. Experiment:
   - Modify any example
   - Add your own code
   - Test Python features!

4. Common patterns:
   - Use f-strings for formatting
   - List comprehensions for transformations
   - Context managers for resource management
   - Decorators for function enhancement

5. Documentation:
   - Python docs: https://docs.python.org
   - Built-in help: help(function_name)
   - Dir for exploring: dir(object)

6. Virtual environment:
   - Make sure your Python environment is configured
   - Check with :!python --version
"""

print("Python playground loaded! Select code and press <leader>px to execute.")
