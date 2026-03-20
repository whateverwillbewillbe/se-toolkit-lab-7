# Development Plan — Telegram Bot for LMS

## Overview

This document outlines the development plan for building a Telegram bot that interacts with the LMS backend. The bot will support slash commands and natural language queries using an LLM for intent routing.

## Task 1: Scaffold and Architecture

**Goal:** Create a testable project structure with `--test` mode.

**Approach:**
- Separate handlers from Telegram transport layer (separation of concerns)
- Handlers are plain functions: `def handle_command(text: str) -> str`
- `--test` mode calls handlers directly without Telegram connection
- Entry point (`bot.py`) handles CLI args and Telegram startup

**Deliverables:**
- `bot/bot.py` — entry point with `--test` mode
- `bot/handlers/` — command handlers (no Telegram dependency)
- `bot/config.py` — environment variable loading
- `bot/pyproject.toml` — dependencies
- `bot/PLAN.md` — this file

## Task 2: Backend Integration

**Goal:** Connect handlers to the LMS backend API.

**Approach:**
- Create API client service with Bearer token authentication
- Implement `/health`, `/labs`, `/scores` handlers with real data
- Handle errors gracefully (backend down → friendly message)
- All API URLs and keys from environment variables

**Deliverables:**
- `bot/services/api_client.py` — HTTP client for LMS API
- Updated handlers with real API calls
- Error handling for network failures

## Task 3: Intent-Based Natural Language Routing

**Goal:** Enable plain text queries using LLM tool calling.

**Approach:**
- Create LLM client service
- Define tool descriptions for each backend endpoint
- Intent router uses LLM to decide which tool to call
- Tool descriptions must be clear for accurate routing

**Deliverables:**
- `bot/services/llm_client.py` — LLM API client
- `bot/handlers/intent_router.py` — LLM-based routing
- Tool definitions for all 9 backend endpoints

## Task 4: Containerization and Deployment

**Goal:** Deploy bot alongside backend on VM.

**Approach:**
- Create Dockerfile for bot
- Add bot service to `docker-compose.yml`
- Configure Docker networking (service names, not localhost)
- Document deployment process

**Deliverables:**
- `bot/Dockerfile`
- Updated `docker-compose.yml`
- Deployment documentation in README

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  bot.py (entry point)                                       │
│  ├── --test mode → calls handlers directly                  │
│  └── Telegram mode → receives updates → calls handlers      │
│                                                             │
│  handlers/                                                  │
│  ├── start.py, help.py, health.py, labs.py, scores.py      │
│  └── intent_router.py (Task 3)                              │
│                                                             │
│  services/                                                  │
│  ├── api_client.py → LMS Backend (FastAPI)                  │
│  └── llm_client.py → LLM API (Task 3)                       │
└─────────────────────────────────────────────────────────────┘
```

## Key Design Decisions

1. **Testable handlers** — handlers don't import Telegram libraries, making them easy to test offline.
2. **Environment-based config** — secrets never in code, loaded from `.env.bot.secret`.
3. **Service layer abstraction** — API and LLM clients are separate from business logic.
4. **Graceful degradation** — if backend is down, bot responds with friendly message, not crash.
