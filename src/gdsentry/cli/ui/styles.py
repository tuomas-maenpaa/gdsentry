"""Style constants and formatting helpers."""

# Style constants for consistent formatting
STYLE_SUCCESS = "green bold"
STYLE_ERROR = "red bold"
STYLE_WARNING = "yellow"
STYLE_INFO = "cyan"
STYLE_CODE = "magenta"
STYLE_PATH = "blue"
STYLE_VALUE = "green"
STYLE_KEY = "cyan bold"
STYLE_DIM = "dim"

# Emoji constants
EMOJI_SUCCESS = "✓"
EMOJI_ERROR = "✗"
EMOJI_WARNING = "⚠"
EMOJI_INFO = "ℹ"
EMOJI_ROCKET = "🚀"
EMOJI_GEAR = "⚙"
EMOJI_TEST = "🧪"
EMOJI_BUILD = "🏗️"
EMOJI_DOCS = "📚"
EMOJI_CHECK = "✅"
EMOJI_CROSS = "❌"


def format_path(path: str) -> str:
    """Format a file path with styling."""
    return f"[{STYLE_PATH}]{path}[/{STYLE_PATH}]"


def format_code(code: str) -> str:
    """Format code/command with styling."""
    return f"[{STYLE_CODE}]{code}[/{STYLE_CODE}]"


def format_value(value: str) -> str:
    """Format a value with styling."""
    return f"[{STYLE_VALUE}]{value}[/{STYLE_VALUE}]"


def format_key(key: str) -> str:
    """Format a key/label with styling."""
    return f"[{STYLE_KEY}]{key}[/{STYLE_KEY}]"

