"""Command handlers for the Telegram bot.

Handlers are plain functions that take input and return text.
They don't know about Telegram - same logic works from --test mode,
unit tests, or Telegram.
"""

from .start import handle_start
from .help import handle_help
from .health import handle_health
from .labs import handle_labs
from .scores import handle_scores

__all__ = [
    "handle_start",
    "handle_help",
    "handle_health",
    "handle_labs",
    "handle_scores",
    "get_handler_for_command",
]


def get_handler_for_command(command: str):
    """Get the handler function for a command.
    
    Args:
        command: Command name without slash (e.g., "start", "help")
    
    Returns:
        Handler function or None if command not found.
    """
    handlers = {
        "start": handle_start,
        "help": handle_help,
        "health": handle_health,
        "labs": handle_labs,
        "scores": handle_scores,
    }
    return handlers.get(command)
