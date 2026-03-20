"""Handler for /scores command."""

from config import load_config
from services.lms_client import create_lms_client


def handle_scores(lab_name: str = "") -> str:
    """Handle the /scores command.

    Args:
        lab_name: Name of the lab to get scores for.

    Returns:
        Scores information for the specified lab.
    """
    if not lab_name:
        return "Please specify a lab name. Example: /scores lab-01"

    config = load_config()
    client = create_lms_client(config)
    result = client.get_scores(lab_name)

    if not result["success"]:
        return f"Error: {result['error']}"

    scores = result["scores"]
    if not scores:
        return f"No scores available for {lab_name}."

    lines = [f"Pass rates for {lab_name}:"]
    for score in scores:
        if isinstance(score, dict):
            task_name = score.get("task", score.get("task_name", "Unknown"))
            pass_rate = score.get("pass_rate", score.get("rate", 0))
            attempts = score.get("attempts", 0)

            # Format percentage
            if isinstance(pass_rate, float):
                percentage = f"{pass_rate * 100:.1f}%"
            else:
                percentage = f"{pass_rate}%"

            if attempts > 0:
                lines.append(f"- {task_name}: {percentage} ({attempts} attempts)")
            else:
                lines.append(f"- {task_name}: {percentage}")

    return "\n".join(lines)
