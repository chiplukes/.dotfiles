--[[
Python Snippets for LuaSnip
Comprehensive collection of Python snippets for common development patterns
Optimized for scientific computing, data analysis, and general Python development
--]]

local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

-- Utility functions for dynamic snippets
local function get_class_name()
  local filename = vim.fn.expand('%:t:r')
  -- Convert snake_case to PascalCase
  return filename:gsub('_(%l)', string.upper):gsub('^%l', string.upper)
end

local function get_current_date()
  return os.date('%Y-%m-%d')
end

local function get_author()
  return vim.fn.system('git config user.name'):gsub('\n', '') or 'Your Name'
end

return {
  -- =============================================================================
  -- Basic Python Structures
  -- =============================================================================
  
  -- Shebang and encoding
  s('shebang', {
    t('#!/usr/bin/env python3'),
    t({ '', '# -*- coding: utf-8 -*-', '' }),
  }),

  -- File header with docstring
  s('header', fmt([[
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
{title}

{description}

Author: {author}
Date: {date}
"""

{body}
]], {
    title = i(1, 'Module Title'),
    description = i(2, 'Brief description of the module'),
    author = f(get_author),
    date = f(get_current_date),
    body = i(0),
  })),

  -- =============================================================================
  -- Classes and Methods
  -- =============================================================================
  
  -- Class definition with common methods
  s('class', fmt([[
class {class_name}:
    """
    {docstring}
    """
    
    def __init__(self{init_params}):
        """Initialize {class_name}."""
        {init_body}
    
    def __str__(self):
        """Return string representation."""
        return f"{{{repr_format}}}"
    
    def __repr__(self):
        """Return detailed representation."""
        return f"{class_name}({repr_params})"
    
    {methods}
]], {
    class_name = f(get_class_name),
    docstring = i(1, 'Class description'),
    init_params = i(2),
    init_body = i(3, 'pass'),
    repr_format = i(4, 'self'),
    repr_params = i(5, ''),
    methods = i(0),
  })),

  -- Method definition
  s('def', fmt([[
def {func_name}({params}){return_type}:
    """
    {docstring}
    
    Args:
        {args}
    
    Returns:
        {returns}
    """
    {body}
]], {
    func_name = i(1, 'function_name'),
    params = i(2),
    return_type = c(3, { t(''), fmt(' -> {}', { i(1, 'ReturnType') }) }),
    docstring = i(4, 'Function description'),
    args = i(5, 'param: Description'),
    returns = i(6, 'Description of return value'),
    body = i(0, 'pass'),
  })),

  -- Property decorator
  s('prop', fmt([[
@property
def {name}(self){return_type}:
    """Get {description}."""
    return self._{name}

@{name}.setter
def {name}(self, value{param_type}):
    """Set {description}."""
    self._{name} = value
]], {
    name = i(1, 'property_name'),
    return_type = c(2, { t(''), fmt(' -> {}', { i(1, 'type') }) }),
    description = i(3, 'property description'),
    param_type = c(4, { t(''), fmt(': {}', { i(1, 'type') }) }),
  })),

  -- =============================================================================
  -- Data Science and Analysis
  -- =============================================================================
  
  -- Standard imports for data science
  s('imports_ds', {
    t({
      'import numpy as np',
      'import pandas as pd',
      'import matplotlib.pyplot as plt',
      'import seaborn as sns',
      'from pathlib import Path',
      '',
    }),
  }),

  -- Pandas DataFrame operations
  s('df', fmt([[
# Load and explore data
df = pd.read_{format}({file_path})
print(f"Shape: {{df.shape}}")
print(f"Columns: {{df.columns.tolist()}}")
print(f"Info:")
df.info()

# Basic statistics
df.describe()
]], {
    format = c(1, { t('csv'), t('excel'), t('json'), t('parquet') }),
    file_path = i(2, '"data.csv"'),
  })),

  -- Matplotlib plotting template
  s('plot', fmt([[
# Create figure and axis
fig, ax = plt.subplots(figsize=({width}, {height}))

# Plot data
{plot_code}

# Customize plot
ax.set_title('{title}')
ax.set_xlabel('{xlabel}')
ax.set_ylabel('{ylabel}')
ax.grid(True, alpha=0.3)

# Show/save plot
plt.tight_layout()
{save_or_show}
]], {
    width = i(1, '10'),
    height = i(2, '6'),
    plot_code = i(3, 'ax.plot(x, y)'),
    title = i(4, 'Plot Title'),
    xlabel = i(5, 'X Label'),
    ylabel = i(6, 'Y Label'),
    save_or_show = c(7, { 
      t('plt.show()'),
      fmt('plt.savefig("{}")\nplt.show()', { i(1, 'plot.png') })
    }),
  })),

  -- =============================================================================
  -- Testing and Debugging
  -- =============================================================================
  
  -- Unit test class
  s('test', fmt([[
import unittest
from unittest.mock import Mock, patch, MagicMock

class Test{class_name}(unittest.TestCase):
    """Test cases for {class_name}."""
    
    def setUp(self):
        """Set up test fixtures."""
        {setup}
    
    def test_{test_name}(self):
        """Test {test_description}."""
        # Arrange
        {arrange}
        
        # Act
        {act}
        
        # Assert
        {assert_code}
    
    {additional_tests}

if __name__ == '__main__':
    unittest.main()
]], {
    class_name = i(1, 'MyClass'),
    setup = i(2, 'pass'),
    test_name = i(3, 'basic_functionality'),
    test_description = i(4, 'basic functionality works correctly'),
    arrange = i(5, '# Set up test data'),
    act = i(6, '# Execute the function'),
    assert_code = i(7, 'self.assertEqual(result, expected)'),
    additional_tests = i(0),
  })),

  -- Pytest test function
  s('pytest', fmt([[
def test_{test_name}({fixtures}):
    """Test {description}."""
    # Arrange
    {arrange}
    
    # Act
    {act}
    
    # Assert
    {assert_code}
]], {
    test_name = i(1, 'function_name'),
    fixtures = i(2),
    description = i(3, 'that function works correctly'),
    arrange = i(4, '# Set up test data'),
    act = i(5, '# Execute the function'),
    assert_code = i(6, 'assert result == expected'),
  })),

  -- =============================================================================
  -- Common Patterns
  -- =============================================================================
  
  -- Context manager
  s('with', fmt([[
with {context} as {var}:
    {body}
]], {
    context = i(1, 'open("file.txt")'),
    var = i(2, 'f'),
    body = i(0, 'pass'),
  })),

  -- Try-except block
  s('try', fmt([[
try:
    {try_body}
except {exception} as {var}:
    {except_body}
{finally_block}
]], {
    try_body = i(1, 'pass'),
    exception = c(2, { t('Exception'), i(1, 'SpecificException') }),
    var = i(3, 'e'),
    except_body = i(4, 'print(f"Error: {e}")'),
    finally_block = c(5, { 
      t(''),
      sn(nil, fmt([[
finally:
    {finally_body}
]], { finally_body = i(1, 'pass') }))
    }),
  })),

  -- List comprehension
  s('lc', fmt('[{expr} for {var} in {iterable}{condition}]', {
    expr = i(1, 'item'),
    var = i(2, 'item'),
    iterable = i(3, 'iterable'),
    condition = c(4, { t(''), fmt(' if {cond}', { cond = i(1, 'condition') }) }),
  })),

  -- Dictionary comprehension
  s('dc', fmt('{{{key}: {value} for {var} in {iterable}{condition}}}', {
    key = i(1, 'key'),
    value = i(2, 'value'),
    var = i(3, 'item'),
    iterable = i(4, 'iterable'),
    condition = c(5, { t(''), fmt(' if {cond}', { cond = i(1, 'condition') }) }),
  })),

  -- Lambda function
  s('lambda', fmt('lambda {params}: {body}', {
    params = i(1, 'x'),
    body = i(2, 'x'),
  })),

  -- =============================================================================
  -- Virtual Environment and Package Management
  -- =============================================================================
  
  -- Requirements.txt template
  s('requirements', {
    t({
      '# Core dependencies',
      'numpy>=1.21.0',
      'pandas>=1.3.0',
      '',
      '# Development dependencies',
      'pytest>=6.0.0',
      'black>=21.0.0',
      'ruff>=0.1.0',
      'mypy>=0.910',
      '',
      '# Optional dependencies',
      '# matplotlib>=3.4.0',
      '# seaborn>=0.11.0',
      '',
    }),
  }),

  -- Logging setup
  s('logging', fmt([[
import logging
from pathlib import Path

# Configure logging
log_format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
logging.basicConfig(
    level=logging.{level},
    format=log_format,
    handlers=[
        logging.FileHandler({log_file}),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
]], {
    level = c(1, { t('INFO'), t('DEBUG'), t('WARNING'), t('ERROR') }),
    log_file = i(2, '"app.log"'),
  })),

  -- Dataclass
  s('dataclass', fmt([[
from dataclasses import dataclass{imports}

@dataclass{decorator_params}
class {class_name}:
    """
    {docstring}
    """
    {fields}
    
    {methods}
]], {
    imports = c(1, { 
      t(''),
      t(', field'),
      t(', field, Field'),
    }),
    decorator_params = c(2, {
      t(''),
      t('(frozen=True)'),
      t('(order=True)'),
    }),
    class_name = i(3, 'DataClass'),
    docstring = i(4, 'Data class description'),
    fields = i(5, 'field_name: str'),
    methods = i(0),
  })),

  -- Type hints
  s('typing', {
    t({
      'from typing import (',
      '    Any, Dict, List, Optional, Union,',
      '    Callable, Tuple, Set, Generator,',
      '    TypeVar, Generic, Protocol',
      ')',
      '',
    }),
  }),
}