"""Handler for /health command."""

from config import load_config
from services.lms_client import create_lms_client


def handle_health() -> str:
    """Handle the /health command.

    Returns:
        Backend health status.
    """
    config = load_config()
    client = create_lms_client(config)
    result = client.health_check()

    return result["message"]
