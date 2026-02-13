"""Shared test fixtures and configuration for pytest."""

from __future__ import annotations

import pytest


@pytest.fixture
def sample_data() -> dict:
    """Provide sample test data. Customize for your project."""
    return {"key": "value"}
