"""Intent router using LLM for natural language understanding."""

import json
import sys
from typing import Any
from config import load_config
from services.llm_client import create_llm_client, LLMClient
from services.lms_client import create_lms_client, LMSClient


# System prompt for the LLM
SYSTEM_PROMPT = """You are a helpful assistant for a Learning Management System (LMS).
You have access to tools that fetch data from the backend API.

When a user asks a question:
1. Analyze what information they need
2. Call the appropriate tool(s) to get that data
3. Use the tool results to formulate a helpful answer

Available tools:
- get_items: List all labs and tasks
- get_learners: List enrolled students
- get_scores: Score distribution for a lab
- get_pass_rates: Per-task pass rates for a lab
- get_timeline: Submissions timeline for a lab
- get_groups: Per-group performance for a lab
- get_top_learners: Top students for a lab
- get_completion_rate: Completion percentage for a lab
- trigger_sync: Refresh data from autochecker

User may click keyboard buttons like "📚 Available labs" or "🏥 Health check" — treat these as requests for that information.
For questions about specific labs, the tool parameters will include the lab identifier.
For multi-step questions (e.g., "which lab has lowest pass rate"), call tools for each lab and compare.

If the user's message is a greeting or unclear, respond naturally without calling tools.
If you don't have enough information, ask for clarification.
"""


def execute_tool(tool_name: str, arguments: dict, lms_client: LMSClient) -> Any:
    """Execute a tool call and return the result.

    Args:
        tool_name: Name of the tool to call
        arguments: Tool arguments
        lms_client: LMS API client

    Returns:
        Tool result (dict or list)
    """
    if tool_name == "get_items":
        result = lms_client.get_labs()
        return result.get("labs", []) if result["success"] else []

    elif tool_name == "get_learners":
        try:
            client = lms_client._get_client()
            response = client.get("/learners/")
            return response.json() if response.status_code == 200 else []
        except Exception:
            return []

    elif tool_name == "get_scores":
        lab = arguments.get("lab", "")
        result = lms_client.get_scores(lab)
        return result.get("scores", []) if result["success"] else []

    elif tool_name == "get_pass_rates":
        lab = arguments.get("lab", "")
        try:
            client = lms_client._get_client()
            response = client.get("/analytics/pass-rates", params={"lab": lab})
            data = response.json() if response.status_code == 200 else {}
            if isinstance(data, list):
                return data
            return data.get("pass_rates", [])
        except Exception:
            return []

    elif tool_name == "get_timeline":
        lab = arguments.get("lab", "")
        try:
            client = lms_client._get_client()
            response = client.get("/analytics/timeline", params={"lab": lab})
            return response.json() if response.status_code == 200 else []
        except Exception:
            return []

    elif tool_name == "get_groups":
        lab = arguments.get("lab", "")
        try:
            client = lms_client._get_client()
            response = client.get("/analytics/groups", params={"lab": lab})
            return response.json() if response.status_code == 200 else []
        except Exception:
            return []

    elif tool_name == "get_top_learners":
        lab = arguments.get("lab", "")
        limit = arguments.get("limit", 5)
        try:
            client = lms_client._get_client()
            response = client.get(
                "/analytics/top-learners", params={"lab": lab, "limit": limit}
            )
            return response.json() if response.status_code == 200 else []
        except Exception:
            return []

    elif tool_name == "get_completion_rate":
        lab = arguments.get("lab", "")
        try:
            client = lms_client._get_client()
            response = client.get("/analytics/completion-rate", params={"lab": lab})
            data = response.json() if response.status_code == 200 else {}
            return data.get("completion_rate", data.get("rate", 0))
        except Exception:
            return 0

    elif tool_name == "trigger_sync":
        try:
            client = lms_client._get_client()
            response = client.post("/pipeline/sync", json={})
            return {"success": response.status_code == 200}
        except Exception:
            return {"success": False}

    return {"error": f"Unknown tool: {tool_name}"}


def route(message: str) -> str:
    """Route a user message through the LLM intent router.

    Args:
        message: User message text

    Returns:
        Response text to send to the user.
    """
    config = load_config()
    llm_client = create_llm_client(config)
    lms_client = create_lms_client(config)

    tools = llm_client.get_tool_definitions()

    # Initialize conversation
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": message},
    ]

    max_iterations = 5
    iteration = 0

    while iteration < max_iterations:
        iteration += 1

        # Call LLM
        try:
            response = llm_client.chat(
                messages=messages, tools=tools, tool_choice="auto"
            )
        except Exception as e:
            print(f"[llm] Error: {e}", file=sys.stderr)
            return f"LLM error: {str(e)}. Please try again later."

        # Check if LLM returned a direct response (no tool calls)
        if not response.get("tool_calls"):
            content = response.get("content", "")
            if content:
                return content
            return "I'm not sure how to help with that. Try asking about labs, scores, or students."

        # Execute tool calls
        tool_results = []
        for tool_call in response["tool_calls"]:
            function = tool_call.get("function", {})
            tool_name = function.get("name", "")
            arguments_str = function.get("arguments", "{}")

            try:
                arguments = (
                    json.loads(arguments_str)
                    if isinstance(arguments_str, str)
                    else arguments_str
                )
            except (json.JSONDecodeError, TypeError):
                arguments = {}

            print(f"[tool] LLM called: {tool_name}({arguments})", file=sys.stderr)

            # Execute the tool
            result = execute_tool(tool_name, arguments, lms_client)
            print(
                f"[tool] Result: {len(result) if isinstance(result, (list, dict)) else result}",
                file=sys.stderr,
            )

            tool_results.append(
                {
                    "tool_call_id": tool_call.get("id", ""),
                    "name": tool_name,
                    "result": result,
                }
            )

        # Feed tool results back to LLM
        print(
            f"[summary] Feeding {len(tool_results)} tool result(s) back to LLM",
            file=sys.stderr,
        )

        # Add assistant's message with tool calls
        messages.append(
            {
                "role": "assistant",
                "content": response.get("content", ""),
                "tool_calls": response["tool_calls"],
            }
        )

        # Add tool results as tool messages
        for tool_result in tool_results:
            messages.append(
                {
                    "role": "tool",
                    "tool_call_id": tool_result["tool_call_id"],
                    "content": json.dumps(tool_result["result"], default=str),
                }
            )

    # If we reach here, the LLM didn't produce a final answer
    return "I had trouble processing your request. Please try rephrasing your question."


def handle_natural_language(message: str) -> str:
    """Handle natural language input.

    Args:
        message: User message text

    Returns:
        Response text.
    """
    # Use LLM router for all messages
    return route(message)
