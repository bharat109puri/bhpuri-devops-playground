import json
from pathlib import Path

from app.main import retrieve


def test_retrieval_evaluation_set_is_grounded():
    cases = json.loads((Path(__file__).parent.parent / "evals" / "retrieval-cases.json").read_text())
    for case in cases:
        sources = {document.metadata["source"] for document in retrieve(case["question"])}
        assert case["required_source"] in sources
