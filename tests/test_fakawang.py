"""Tests for fakawang module"""

import unittest
from fakawang import greet


class TestFakawang(unittest.TestCase):
    """Test cases for fakawang package"""
    
    def test_greet_default(self):
        """Test greet function with default parameter"""
        result = greet()
        self.assertEqual(result, "Hello, World!")
    
    def test_greet_with_name(self):
        """Test greet function with custom name"""
        result = greet("fakawang")
        self.assertEqual(result, "Hello, fakawang!")


if __name__ == "__main__":
    unittest.main()
