"""
Coverage-specific exceptions
"""


class CoverageError(Exception):
    """Base exception for coverage system errors"""
    pass


class ParseError(CoverageError):
    """Raised when GDScript parsing fails"""
    pass


class InstrumentationError(CoverageError):
    """Raised when instrumentation fails"""
    pass
