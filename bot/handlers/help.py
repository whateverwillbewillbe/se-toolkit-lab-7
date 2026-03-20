"""Handler for /help command."""


def handle_help() -> str:
    """Handle the /help command.
    
    Returns:
        List of available commands.
    """
    return """Available commands:

/start - Welcome message
/help - Show this help message
/health - Check backend system status
/labs - List available labs
/scores <lab> - View scores for a specific lab

You can also ask questions in plain language (coming soon)."""
