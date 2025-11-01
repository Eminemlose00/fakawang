"""
fakawang - A Python package
"""

__version__ = "0.1.0"

def greet(name="World"):
    """
    Return a greeting message.
    
    Args:
        name (str): The name to greet. Defaults to "World".
    
    Returns:
        str: A greeting message.
    """
    return f"Hello, {name}!"

__all__ = ["greet"]
