"""Handler for /labs command."""

from config import load_config
from services.lms_client import create_lms_client


def handle_labs() -> str:
    """Handle the /labs command.

    Returns:
        List of available labs.
    """
    config = load_config()
    client = create_lms_client(config)
    result = client.get_labs()

    if not result["success"]:
        return f"Error fetching labs: {result['error']}"

    labs = result["labs"]
    if not labs:
        return "No labs available."

    lines = ["Available labs:"]
    for lab in labs:
        # Use title if available, otherwise fall back to name/id
        title = lab.get("title", lab.get("name", lab.get("id", "Unknown")))
        lab_id = lab.get("id", "")
        description = lab.get("description", "")

        # Format: "- Lab 01 — Products, Architecture & Roles"
        if description:
            lines.append(f"- {title} — {description}")
        else:
            lines.append(f"- {title}")

    return "\n".join(lines)
