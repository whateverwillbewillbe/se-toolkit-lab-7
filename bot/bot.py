"""Telegram bot entry point.

Usage:
    uv run bot.py           # Start Telegram bot
    uv run bot.py --test "/start"  # Test mode (no Telegram connection)
"""

import argparse
import sys
from pathlib import Path

# Add bot directory to path for imports
bot_dir = Path(__file__).parent
sys.path.insert(0, str(bot_dir))

from config import load_config
from handlers import get_handler_for_command


def parse_command(text: str) -> tuple[str, str]:
    """Parse a command text into command and arguments.
    
    Args:
        text: Input text (e.g., "/scores lab-01" or "/start")
    
    Returns:
        Tuple of (command, args)
    """
    text = text.strip()
    if text.startswith("/"):
        text = text[1:]
    
    parts = text.split(maxsplit=1)
    command = parts[0] if parts else ""
    args = parts[1] if len(parts) > 1 else ""
    
    return command, args


def run_test_mode(command_text: str) -> None:
    """Run a command in test mode (no Telegram connection).
    
    Args:
        command_text: Command to test (e.g., "/start", "/health")
    """
    config = load_config()
    
    command, args = parse_command(command_text)
    handler = get_handler_for_command(command)
    
    if handler is None:
        print(f"Unknown command: /{command}")
        print("Use /help to see available commands.")
        sys.exit(1)
    
    # Call handler with or without arguments
    if args:
        response = handler(args)
    else:
        response = handler()
    
    print(response)
    sys.exit(0)


def run_telegram_mode() -> None:
    """Start the Telegram bot (not implemented in Task 1)."""
    config = load_config()
    
    if not config["BOT_TOKEN"]:
        print("Error: BOT_TOKEN not set in .env.bot.secret")
        print("Please configure your bot token before starting.")
        sys.exit(1)
    
    # Telegram bot implementation will be added in Task 2
    print("Telegram bot mode will be implemented in Task 2.")
    print("For now, use --test mode to test handlers.")


def main() -> None:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="LMS Telegram Bot",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    uv run bot.py --test "/start"
    uv run bot.py --test "/help"
    uv run bot.py --test "/health"
    uv run bot.py --test "/labs"
    uv run bot.py --test "/scores lab-01"
        """
    )
    parser.add_argument(
        "--test",
        metavar="COMMAND",
        help="Run a command in test mode (no Telegram connection)"
    )
    
    args = parser.parse_args()
    
    if args.test:
        run_test_mode(args.test)
    else:
        run_telegram_mode()


if __name__ == "__main__":
    main()
